# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require 'logstash/outputs/sns'
require 'logstash/event'
require "logstash/plugin_mixins/aws_config"

require "aws-sdk" # TODO: Why is this not automatically brought in by the aws_config plugin?

describe LogStash::Outputs::Sns do
  describe "sending an SNS notification" do
    let(:arn) { "arn:aws:sns:us-east-1:999999999:logstash-test-sns-topic" }
    let(:sns_subject) { "The Pain in Spain" }
    let(:sns_message) { "That's where the rain falls, plainly." }
    let(:mock_client) { double("Aws::SNS::Client") }
    let(:good_publish_args) {
      {
        :topic_arn => arn,
        :subject => sns_subject,
        :message => sns_message
      }
    }
    subject {
      allow(Aws::SNS::Client).to receive(:new).and_return(mock_client)
      instance = LogStash::Outputs::Sns.new
      allow(instance).to receive(:publish_boot_message_arn).and_return(nil)
      instance.register
      instance
    }

    it "should raise an ArgumentError if no arn is provided" do
      expect {
        subject.send(:send_sns_message, nil, sns_subject, sns_message)
      }.to raise_error(ArgumentError)
    end

    it "should send a well formed message through to SNS" do
      expect(mock_client).to receive(:publish).with(good_publish_args)
      subject.send(:send_sns_message, arn, sns_subject, sns_message)
    end

    it "should attempt to publish a boot message" do
      expect(subject).to have_received(:publish_boot_message_arn).once
    end

    # TODO: Write a unicode aware version of this...
    it "should truncate long messages before sending" do
      max_size = LogStash::Outputs::Sns::MAX_MESSAGE_SIZE_IN_BYTES
      long_message = "A" * (max_size + 1)
      expect(mock_client).to receive(:publish) {|args|
                               expect(args[:message].bytesize).to eql(max_size)
                             }

      subject.send(:send_sns_message, arn, sns_subject, long_message)
    end

    it "should truncate long subjects before sending" do
      max_size = LogStash::Outputs::Sns::MAX_SUBJECT_SIZE_IN_CHARACTERS
      long_subject = "A" * (max_size + 1)
      expect(mock_client).to receive(:publish) {|args|
                               expect(args[:subject].bytesize).to eql(max_size)
                             }

      subject.send(:send_sns_message, arn, long_subject, sns_message)
    end
  end
end
