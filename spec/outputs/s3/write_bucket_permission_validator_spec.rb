# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "aws-sdk-s3"
require "logstash/outputs/s3/write_bucket_permission_validator"

describe LogStash::Outputs::S3::WriteBucketPermissionValidator do
  let(:logger) { spy(:logger ) }
  let(:bucket_name) { "foobar" }
  let(:obj) { double("s3_object") }
  let(:tm) { double("transfer_manager") }
  let(:client) { Aws::S3::Client.new(stub_responses: true) }
  let(:bucket) { Aws::S3::Bucket.new(bucket_name, :client => client) }
  let(:upload_options) { {} }

  subject { described_class.new(logger) }

  before do
    allow(Aws::S3::TransferManager).to receive(:new).with(client: client).and_return(tm)
    allow(bucket).to receive(:object).with(any_args).and_return(obj)
  end

  context 'when using upload_options' do
    let(:upload_options) {{ :server_side_encryption => true }}
    it 'they are passed through to upload_file' do
      expect(tm).to receive(:upload_file).with(anything, hash_including(upload_options))
      expect(obj).to receive(:delete).and_return(true)
      expect(subject.valid?(bucket, upload_options)).to be_truthy
    end

  end

  context "when permissions are sufficient" do
    it "returns true" do
      expect(tm).to receive(:upload_file).with(any_args).and_return(true)
      expect(obj).to receive(:delete).and_return(true)
      expect(subject.valid?(bucket, upload_options)).to be_truthy
    end

    it "hides delete errors" do
      expect(tm).to receive(:upload_file).with(any_args).and_return(true)
      expect(obj).to receive(:delete).and_raise(StandardError)
      expect(subject.valid?(bucket, upload_options)).to be_truthy
    end
  end

  context "when permission aren't sufficient" do
    it "returns false" do
      expect(tm).to receive(:upload_file).with(any_args).and_raise(StandardError)
      expect(subject.valid?(bucket, upload_options)).to be_falsey
    end
  end
end
