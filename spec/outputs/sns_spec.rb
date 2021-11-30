# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require 'logstash/outputs/sns'
require 'logstash/event'
require "logstash/plugin_mixins/aws_config"

require "aws-sdk" # TODO: Why is this not automatically brought in by the aws_config plugin?

describe LogStash::Outputs::Sns do
  let(:arn) { "arn:aws:sns:us-east-1:999999999:logstash-test-sns-topic" }
  let(:sns_subject) { "The Plain in Spain" }
  let(:sns_message) { "That's where the rain falls, plainly." }
  let(:mock_client) { double("Aws::SNS::Client") }
  let(:instance) {
    allow(Aws::SNS::Client).to receive(:new).and_return(mock_client)
    inst = LogStash::Outputs::Sns.new
    allow(inst).to receive(:publish_boot_message_arn).and_return(nil)
    inst.register
    inst
  }

  describe "receiving an event" do
    let(:expected_subject) { double("expected_subject")}
    subject {
      inst = instance
      allow(inst).to receive(:send_sns_message).with(any_args)
      allow(inst).to receive(:event_subject).
                       with(any_args).
                       and_return(expected_subject)
      inst.receive(event)
      inst
    }

    shared_examples("publishing correctly") do
      it "should send a message to the correct ARN if the event has 'arn' set" do
        expect(subject).to have_received(:send_sns_message).with(arn, anything, anything)
      end

      it "should send the message" do
        expect(subject).to have_received(:send_sns_message).with(anything, anything, expected_message)
      end

      it "should send the subject" do
        expect(subject).to have_received(:send_sns_message).with(anything, expected_subject, anything)
      end
    end

    describe "with an explicit message" do
      let(:expected_subject) { sns_subject }
      let(:expected_message) { sns_message }
      let(:event) { LogStash::Event.new("sns" => arn, "sns_subject" => sns_subject,
                                        "sns_message" => sns_message) }
      include_examples("publishing correctly")
    end

    describe "without an explicit message" do
      # Testing codecs sucks. It'd be nice if codecs had to implement some sort of encode_sync method
      let(:expected_message) {
        c = subject.codec.clone
        result = nil;
        c.on_event {|event, encoded| result = encoded }
        c.encode(event)
        result
      }
      let(:event) { LogStash::Event.new("sns" => arn, "sns_subject" => sns_subject) }

      include_examples("publishing correctly")
    end
  end

  describe "determining the subject" do
    it "should return 'sns_subject' when set" do
      event = LogStash::Event.new("sns_subject" => "foo")
      expect(subject.send(:event_subject, event)).to eql("foo")
    end

    it "should return the sns subject as JSON if not a string" do
      event = LogStash::Event.new("sns_subject" => ["foo", "bar"])
      expect(subject.send(:event_subject, event)).to eql(LogStash::Json.dump(["foo", "bar"]))
    end

    it "should return the host if 'sns_subject' not set" do
      event = LogStash::Event.new("host" => "foo")
      expect(subject.send(:event_subject, event)).to eql("foo")
    end

    it "should return the host name (ECS compatibility) if 'sns_subject' not set" do
      event = LogStash::Event.new
      event.set('[host][hostname]', 'server1')
      expect(subject.send(:event_subject, event)).to eql('server1')
    end

    it "should return the host IP (ECS compatibility) if 'sns_subject' not set" do
      event = LogStash::Event.new
      event.set('host.geo.name', 'Vychodne Pobrezie')
      expect(subject.send(:event_subject, event)).to eql(LogStash::Outputs::Sns::NO_SUBJECT)
    end

    it "should return no subject when no info in host object (ECS compatibility) if 'sns_subject' not set" do
      event = LogStash::Event.new
      event.set('[host][ip]', '192.168.1.111')
      expect(subject.send(:event_subject, event)).to eql('192.168.1.111')
    end

    it "should return 'NO SUBJECT' when subject cannot be determined" do
      event = LogStash::Event.new("foo" => "bar")
      expect(subject.send(:event_subject, event)).to eql(LogStash::Outputs::Sns::NO_SUBJECT)
    end
  end

  describe "sending an SNS notification" do
    let(:good_publish_args) {
      {
        :topic_arn => arn,
        :subject => sns_subject,
        :message => sns_message
      }
    }
    let(:long_message) { "A" * (LogStash::Outputs::Sns::MAX_MESSAGE_SIZE_IN_BYTES + 1) }
    let(:long_subject) { "S" * (LogStash::Outputs::Sns::MAX_SUBJECT_SIZE_IN_CHARACTERS + 1) }
    subject { instance }

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
      x = case "foo"
            when "bar"
              "hello"
          end
    end

    it "should truncate long messages before sending" do
      max_size = LogStash::Outputs::Sns::MAX_MESSAGE_SIZE_IN_BYTES
      expect(mock_client).to receive(:publish) {|args|
                               expect(args[:message].bytesize).to eql(max_size)
                             }

      subject.send(:send_sns_message, arn, sns_subject, long_message)
    end

    it "should truncate long subjects before sending" do
      max_size = LogStash::Outputs::Sns::MAX_SUBJECT_SIZE_IN_CHARACTERS
      expect(mock_client).to receive(:publish) {|args|
                               expect(args[:subject].bytesize).to eql(max_size)
                             }

      subject.send(:send_sns_message, arn, long_subject, sns_message)
    end
  end
end
