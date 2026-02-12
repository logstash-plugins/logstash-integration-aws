require "logstash/outputs/base"
require "logstash/namespace"
require 'logstash/plugin_mixins/aws_config'

require "aws-sdk-firehose"

# Push events to an Amazon Web Services (AWS) Data Firehose.
#
# Amazon Data Firehose is a fully managed service for delivering real-time streaming data to destinations
# such as Amazon services or HTTP endpoints owned by supported third-party service providers.
# See : https://docs.aws.amazon.com/firehose/latest/dev/what-is-this-service.html
#
# This plugin use the AWS SDK to send data to the Firehose stream.
# See https://docs.aws.amazon.com/firehose/latest/dev/basic-write.html#writing-with-sdk
#
# Your identity must have the following permissions on the stream:
#   * `firehose:PutRecordBatch`
#
# ==== Batch Publishing
# This output publishes messages to Firehose in batches in order to optimize event throughput and increase performance.
# This is done using the `PutRecordBatch` API.
# See https://docs.aws.amazon.com/firehose/latest/APIReference/API_PutRecordBatch.html
#
# When publishing messages to Firehose in batches, the following service limits must be respected :
#   * Each PutRecordBatch request supports up to 500 records.
#   * Each record in the request can be as large as 1,000 KB.
#   * All records in the request can be as large as 4 MB.
#
# This plugin will dynamically adjust the size of the batch published to Firehose in
# order to ensure that the total payload size does not exceed the limits.
#
class LogStash::Outputs::Firehose < LogStash::Outputs::Base
  include LogStash::PluginMixins::AwsConfig::V2

  RECORDS_MAX_BATCH_COUNT = 500
  RECORD_MAX_SIZE_BYTES = 1_000_000
  RECORD_TOTAL_MAX_SIZE_BYTES = 4_000_000
  REQUEST_RETRY_INTERVAL_SECONDS = 2

  config_name "firehose"
  concurrency :shared
  default :codec, 'json'

  # The name of the delivery stream.
  # Note that this is just the name of the stream, not the URL or ARN.
  config :delivery_stream_name, :validate => :string, :required => true

  # The maximum number of records to be sent in each batch.
  config :batch_max_count, :validate => :number, :default => RECORDS_MAX_BATCH_COUNT

  # The maximum number of bytes for any record sent to Firehose.
  # Messages exceeding this size will be dropped.
  # See https://docs.aws.amazon.com/firehose/latest/APIReference/API_PutRecordBatch.html
  config :record_max_size_bytes, :validate => :bytes, :default => RECORD_MAX_SIZE_BYTES

  # The maximum number of bytes for all records sent to Firehose.
  # See https://docs.aws.amazon.com/firehose/latest/APIReference/API_PutRecordBatch.html
  config :record_total_max_size_bytes, :validate => :bytes, :default => RECORD_TOTAL_MAX_SIZE_BYTES

  def register
    if @batch_max_count > RECORDS_MAX_BATCH_COUNT
      raise LogStash::ConfigurationError, "The maximum batch size is #{RECORDS_MAX_BATCH_COUNT} records"
    elsif @batch_max_count < 1
      raise LogStash::ConfigurationError, 'The batch size must be greater than 0'
    end

    if @record_max_size_bytes > RECORD_MAX_SIZE_BYTES
      raise LogStash::ConfigurationError, "The maximum record size is #{RECORD_MAX_SIZE_BYTES}"
    elsif @record_max_size_bytes < 1
      raise LogStash::ConfigurationError, 'The record size must be greater than 0'
    end

    if @record_total_max_size_bytes > RECORD_TOTAL_MAX_SIZE_BYTES
      raise LogStash::ConfigurationError, "The maximum message size is #{RECORD_TOTAL_MAX_SIZE_BYTES}"
    elsif @record_total_max_size_bytes < 1
      raise LogStash::ConfigurationError, 'The message size must be greater than 0'
    end

    @logger.info("New Firehose output", :delivery_stream_name => @delivery_stream_name,
                 :batch_max_count => @batch_max_count,
                 :record_max_size_bytes => @record_max_size_bytes,
                 :record_total_max_size_bytes => @record_total_max_size_bytes)
    @firehose = Aws::Firehose::Client.new(aws_options_hash)
  end

  public def multi_receive_encoded(encoded_events)
    return if encoded_events.empty?

    @logger.debug("Multi receive encoded", :encoded_events => encoded_events)

    records_bytes = 0
    records = []

    encoded_events.each do |_, encoded|

      if encoded.bytesize > @record_max_size_bytes
        @logger.warn('Record exceeds maximum length and will be dropped', :record => encoded, :size => encoded.bytesize)
        next
      end

      if records.size >= @batch_max_count or (records_bytes + encoded.bytesize) > @record_total_max_size_bytes
        put_record_batch(records)
        records_bytes = 0
        records = []
      end

      records_bytes += encoded.bytesize
      records << { :data => encoded }
    end

    put_record_batch(records) unless records.empty?
  end

  def put_record_batch(records)
    return if records.nil? or records.empty?

    @logger.debug("Publishing records", :batch => records.size)

    begin
      put_response = @firehose.put_record_batch({
                                                  delivery_stream_name: @delivery_stream_name,
                                                  records: records
                                                })
    rescue => e
      @logger.error("Encountered an unexpected error submitting a batch request, will retry",
                    message: e.message, exception: e.class, backtrace: e.backtrace)
      Stud.stoppable_sleep(REQUEST_RETRY_INTERVAL_SECONDS)
      retry
    end

    if put_response.failed_put_count == 0
      @logger.debug("Published records successfully", :batch => records.size)
      return
    end

    put_response.request_responses
                .filter { |r| !r.error_code.nil? }
                .each do |response|
      @logger.warn('Record publish error, will be dropped', :response => response)
    end unless put_response.request_responses.nil?

  end
end
