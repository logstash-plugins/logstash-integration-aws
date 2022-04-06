def fetch_events(settings)
  queue = []
  s3 = LogStash::Inputs::S3.new(settings)
  s3.register
  s3.process_files(queue)
  queue
end

# delete_files(prefix)
def upload_file(local_file, remote_name)
  bucket = s3object.bucket(ENV['AWS_LOGSTASH_TEST_BUCKET'])
  file = File.expand_path(File.join(File.dirname(__FILE__), local_file))
  bucket.object(remote_name).upload_file(file)
end

def delete_remote_files(prefix)
  bucket = s3object.bucket(ENV['AWS_LOGSTASH_TEST_BUCKET'])
  bucket.objects(:prefix => prefix).each { |object| object.delete }
end

def list_remote_files(prefix, target_bucket = ENV['AWS_LOGSTASH_TEST_BUCKET'])
  bucket = s3object.bucket(target_bucket)
  bucket.objects(:prefix => prefix).collect(&:key)
end

def create_bucket(name)
  s3object.bucket(name).create
end

def delete_bucket(name)
  s3object.bucket(name).objects.map(&:delete)
  s3object.bucket(name).delete
end

def s3object
  Aws::S3::Resource.new
end

class TestInfiniteS3Object
  def initialize(s3_obj)
    @s3_obj = s3_obj
  end

  def each
    counter = 1

    loop do
      yield @s3_obj
      counter +=1
    end
  end
end

def push_sqs_event(message)
  client = Aws::SQS::Client.new
  queue_url = client.get_queue_url(:queue_name => ENV["SQS_QUEUE_NAME"])

  client.send_message({
    queue_url: queue_url.queue_url,
    message_body: message,
  })
end

shared_context "setup plugin" do
  let(:temporary_directory) { Stud::Temporary.pathname }

  let(:bucket) { ENV["AWS_LOGSTASH_TEST_BUCKET"] }
  let(:access_key_id) {  ENV["AWS_ACCESS_KEY_ID"] }
  let(:secret_access_key) { ENV["AWS_SECRET_ACCESS_KEY"] }
  let(:size_file) { 100 }
  let(:time_file) { 100 }
  let(:tags) { [] }
  let(:prefix) { "home" }
  let(:region) { ENV['AWS_REGION'] }

  let(:main_options) do
    {
      "bucket" => bucket,
      "prefix" => prefix,
      "temporary_directory" => temporary_directory,
      "access_key_id" => access_key_id,
      "secret_access_key" => secret_access_key,
      "size_file" => size_file,
      "time_file" => time_file,
      "region" => region,
      "tags" => []
    }
  end

  let(:client_credentials) { Aws::Credentials.new(access_key_id, secret_access_key) }
  let(:bucket_resource) { Aws::S3::Bucket.new(bucket, { :credentials => client_credentials, :region => region }) }

  subject { LogStash::Outputs::S3.new(options) }
end

def clean_remote_files(prefix = "")
  bucket_resource.objects(:prefix => prefix).each do |object|
    object.delete
  end
end

# Retrieve all available messages from the specified queue.
#
# Rather than utilizing `Aws::SQS::QueuePoller` directly in order to poll an
# SQS queue for messages, this method retrieves and returns all messages that
# are able to be received from the specified SQS queue.
def receive_all_messages(queue_url, options = {})
  options[:idle_timeout] ||= 0
  options[:max_number_of_messages] ||= 10

  messages = []
  poller = Aws::SQS::QueuePoller.new(queue_url, options)

  poller.poll do |received_messages|
    messages.concat(received_messages)
  end

  messages
end
