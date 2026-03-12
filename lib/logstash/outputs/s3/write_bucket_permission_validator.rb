# encoding: utf-8
require "stud/temporary"
require "socket"
require "fileutils"
require "aws-sdk-s3"

module LogStash
  module Outputs
    class S3
      class WriteBucketPermissionValidator
        attr_reader :logger

        def initialize(logger)
          @logger = logger
        end

        def valid?(bucket_resource, upload_options = {})
          begin
            upload_test_file(bucket_resource, upload_options)
            true
          rescue StandardError => e
            logger.error("Error validating bucket write permissions!",
              :message => e.message,
              :class => e.class.name,
              :backtrace => e.backtrace
              )
            false
          end
        end

        private
        def upload_test_file(bucket_resource, upload_options = {})
          generated_at = Time.now

          key = "logstash-programmatic-access-test-object-#{generated_at}"
          content = "Logstash permission check on #{generated_at}, by #{Socket.gethostname}"

          begin
            f = Stud::Temporary.file
            f.write(content)
            f.fsync

            transfer_manager = Aws::S3::TransferManager.new(client: bucket_resource.client)
            transfer_manager.upload_file(f.path, bucket: bucket_resource.name, key: key, **upload_options)

            begin
              bucket_resource.object(key).delete
            rescue
              # Try to remove the files on the remote bucket,
              # but don't raise any errors if that doesn't work.
              # since we only really need `putobject`.
            end
          ensure
            f.close
            FileUtils.rm_rf(f.path)
          end
        end
      end
    end
  end
end
