# encoding: utf-8
require "java"
require "concurrent"
require "concurrent/timer_task"
require "logstash/util"

ConcurrentHashMap = java.util.concurrent.ConcurrentHashMap

module LogStash
  module Outputs
    class S3
      class FileRepository
        DEFAULT_STATE_SWEEPER_INTERVAL_SECS = 60
        DEFAULT_STALE_TIME_SECS = 15 * 60
        # Ensure that all access or work done
        # on a factory is threadsafe
        class PrefixedValue
          def initialize(file_factory, stale_time, logger)
            @file_factory = file_factory
            @lock = Monitor.new # reentrant Mutex
            @stale_time = stale_time
            @is_deleted = false
            @logger = logger
          end

          def with_lock
            @lock.synchronize {
              yield @file_factory
            }
          end

          def remove_staled_files
            with_lock do |factory|
              factory.temp_files = factory.temp_files.delete_if do |temp_file|
                is_staled = temp_file.size == 0 && (Time.now - temp_file.ctime > @stale_time)
                is_temp_dir_empty = false
                begin
                  # checking Dir emptiness and remove file
                  # reading file and checking size doesn't make sense as it will not possible after temp_file.size == 0 filter
                  temp_file.delete! if is_staled
                  is_temp_dir_empty = Dir.empty?(::File.join(temp_file.temp_path, temp_file.prefix)) unless is_staled
                  temp_file.delete! if is_temp_dir_empty
                rescue => e
                  @logger.error("An error occurred while sweeping temp dir.", :exception => e.class, :message => e.message, :path => temp_file.path, :backtrace => e.backtrace)
                end
                is_staled || is_temp_dir_empty
              end
              # mark as deleted once we finish tracking all temp files created
              @is_deleted = factory.temp_files.length == 0
            end
          end

          def apply(prefix)
            return self
          end

          def deleted?
            with_lock { |_| @is_deleted }
          end
        end

        class FactoryInitializer
          include java.util.function.Function
          def initialize(tags, encoding, temporary_directory, stale_time, logger)
            @tags = tags
            @encoding = encoding
            @temporary_directory = temporary_directory
            @stale_time = stale_time
            @logger = logger
          end

          def apply(prefix_key)
            PrefixedValue.new(TemporaryFileFactory.new(prefix_key, @tags, @encoding, @temporary_directory), @stale_time, @logger)
          end
        end

        def initialize(tags, encoding, temporary_directory,
                       stale_time = DEFAULT_STALE_TIME_SECS,
                       sweeper_interval = DEFAULT_STATE_SWEEPER_INTERVAL_SECS, logger)
          # The path need to contains the prefix so when we start
          # Logstash after a crash we keep the remote structure
          @prefixed_factories =  ConcurrentHashMap.new

          @sweeper_interval = sweeper_interval

          @factory_initializer = FactoryInitializer.new(tags, encoding, temporary_directory, stale_time, logger)

          start_stale_sweeper
        end

        def keys
          @prefixed_factories.keySet
        end

        ##
        # Yields the current file of each non-deleted file factory while the current thread has exclusive access to it.
        # @yieldparam file [TemporaryFile]
        # @return [void]
        def each_files
          each_factory(keys) do |factory|
            yield factory.current
          end
          nil # void return avoid leaking unsynchronized access
        end

        ##
        # Yields the file factory while the current thread has exclusive access to it, creating a new
        # one if one does not exist or if the current one is being reaped by the stale watcher.
        # @param prefix_key [String]: the prefix key
        # @yieldparam factory [TemporaryFileFactory]: a temporary file factory that this thread has exclusive access to
        # @return [void]
        def get_factory(prefix_key)
          # fast-path: if factory exists and is not deleted, yield it with exclusive access and return
          prefix_val = @prefixed_factories.get(prefix_key)
          prefix_val&.with_lock do |factory|
            # intentional local-jump to ensure deletion detection
            # is done inside the exclusive access.
            unless prefix_val.deleted?
              yield(factory)
              return nil # void return avoid leaking unsynchronized access
            end
          end

          # slow-path:
          # the ConcurrentHashMap#get operation is lock-free, but may have returned an entry that was being deleted by
          # another thread (such as via stale detection). If we failed to retrieve a value, or retrieved one that had
          # been marked deleted, use the atomic ConcurrentHashMap#compute to retrieve a non-deleted entry.
          prefix_val = @prefixed_factories.compute(prefix_key) do |_, existing|
            existing && !existing.deleted? ? existing : @factory_initializer.apply(prefix_key)
          end
          prefix_val.with_lock { |factory| yield factory }
          nil # void return avoid leaking unsynchronized access
        end

        ##
        # Yields each non-deleted file factory while the current thread has exclusive access to it.
        # @param prefixes [Array<String>]: the prefix keys
        # @yieldparam factory [TemporaryFileFactory]
        # @return [void]
        def each_factory(prefixes)
          prefixes.each do |prefix_key|
            prefix_val = @prefixed_factories.get(prefix_key)
            prefix_val&.with_lock do |factory|
              yield factory unless prefix_val.deleted?
            end
          end
          nil # void return avoid leaking unsynchronized access
        end

        ##
        # Ensures that a non-deleted factory exists for the provided prefix and yields its current file
        # while the current thread has exclusive access to it.
        # @param prefix_key [String]
        # @yieldparam file [TemporaryFile]
        # @return [void]
        def get_file(prefix_key)
          get_factory(prefix_key) { |factory| yield factory.current }
          nil # void return avoid leaking unsynchronized access
        end

        def shutdown
          stop_stale_sweeper
        end

        def size
          @prefixed_factories.size
        end

        def remove_if_stale(prefix_key)
          # we use the ATOMIC `ConcurrentHashMap#computeIfPresent` to atomically
          # detect the staleness, mark a stale prefixed factory as deleted, and delete from the map.
          @prefixed_factories.computeIfPresent(prefix_key) do |_, prefixed_factory|
            # once we have retrieved an instance, we acquire exclusive access to it
            # for stale detection, marking it as deleted before releasing the lock
            # and causing it to become deleted from the map.
            prefixed_factory.with_lock do |_|
              prefixed_factory.remove_staled_files
              if prefixed_factory.deleted?
                nil # cause deletion
              else
                prefixed_factory # keep existing
              end
            end
          end
        end

        def stop_tracking_temp_file(prefix_key, file)
          prefix_val = @prefixed_factories.get(prefix_key)
          prefix_val&.with_lock do |factory|
            factory.temp_files.delete(file)
          end
        end

        def start_stale_sweeper
          @stale_sweeper = Concurrent::TimerTask.new(:execution_interval => @sweeper_interval) do
            LogStash::Util.set_thread_name("S3, Stale factory sweeper")

            @prefixed_factories.keys.each do |prefix|
              remove_if_stale(prefix)
            end
          end

          @stale_sweeper.execute
        end

        def stop_stale_sweeper
          @stale_sweeper.shutdown
        end
      end
    end
  end
end
