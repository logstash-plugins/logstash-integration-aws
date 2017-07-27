# encoding: utf-8

require_relative '../../spec_helper'
require 'logstash/errors'
require 'logstash/event'
require 'logstash/json'

describe LogStash::Outputs::SQS do
  let(:config) do
    {
      'queue' => queue_name,
      'region' => region,
    }
  end
  let(:queue_name) { 'my-sqs-queue' }
  let(:queue_url) { "https://sqs.#{region}.amazonaws.com/123456789012/#{queue_name}" }
  let(:region) { 'us-east-1' }

  let(:sqs) { Aws::SQS::Client.new(:stub_responses => true) }
  subject { described_class.new(config) }

  describe '#register' do
    context 'with a batch size that is too large' do
      let(:config) { super.merge('batch_events' => 100) }

      before do
        allow(Aws::SQS::Client).to receive(:new).and_return(sqs)
      end

      it 'raises a configuration error' do
        expect { subject.register }.to raise_error(LogStash::ConfigurationError)
      end
    end

    context 'with a batch size that is too small' do
      let(:config) { super.merge('batch_events' => 0) }

      before do
        allow(Aws::SQS::Client).to receive(:new).and_return(sqs)
      end

      it 'raises a configuration error' do
        expect { subject.register }.to raise_error(LogStash::ConfigurationError)
      end
    end

    context 'without a queue' do
      let(:config) { Hash.new }

      it 'raises a configuration error' do
        expect { subject.register }.to raise_error(LogStash::ConfigurationError)
      end
    end

    context 'with a nonexistent queue' do
      before do
        expect(Aws::SQS::Client).to receive(:new).and_return(sqs)
        expect(sqs).to receive(:get_queue_url).with(:queue_name => queue_name) do
          raise Aws::SQS::Errors::NonExistentQueue.new(nil, 'The specified queue does not exist for this wsdl version.')
        end
      end

      it 'raises a configuration error' do
        expect { subject.register }.to raise_error(LogStash::ConfigurationError)
      end
    end

    context 'with a valid queue' do
      before do
        expect(Aws::SQS::Client).to receive(:new).and_return(sqs)
        expect(sqs).to receive(:get_queue_url).with(:queue_name => queue_name).and_return(:queue_url => queue_url)
      end

      it 'does not raise an error' do
        expect { subject.register }.not_to raise_error
      end
    end
  end

  describe '#multi_receive_encoded' do
    before do
      expect(Aws::SQS::Client).to receive(:new).and_return(sqs)
      expect(sqs).to receive(:get_queue_url).with(:queue_name => queue_name).and_return(:queue_url => queue_url)
      subject.register
    end

    after do
      subject.close
    end

    let(:sample_count) { 10 }
    let(:sample_event) { LogStash::Event.new('message' => 'This is a message') }
    let(:sample_event_encoded) { LogStash::Json.dump(sample_event) }
    let(:sample_events) do
      sample_count.times.map do
        [sample_event, sample_event_encoded]
      end
    end

    context 'with batching disabled' do
      let(:config) do
        super.merge({
          'batch_events' => 1,
        })
      end

      it 'should call send_message' do
        expect(sqs).to receive(:send_message).with(:queue_url => queue_url, :message_body => sample_event_encoded).exactly(sample_count).times
        subject.multi_receive_encoded(sample_events)
      end

      it 'should not call send_message_batch' do
        expect(sqs).not_to receive(:send_message_batch)
        subject.multi_receive_encoded(sample_events)
      end
    end

    context 'with batching enabled' do
      let(:batch_events) { 3 }
      let(:config) do
        super.merge({
          'batch_events' => batch_events,
        })
      end

      let(:sample_batches) do
        sample_events.each_slice(batch_events).each_with_index.map do |sample_batch, batch_index|
          sample_batch.each_with_index.map do |encoded_event, index|
            event, encoded = encoded_event
            {
              :id => (batch_index * batch_events + index).to_s,
              :message_body => encoded,
            }
          end
        end
      end

      it 'should call send_message_batch' do
        expect(sqs).to receive(:send_message_batch).at_least(:once)
        subject.multi_receive_encoded(sample_events)
      end

      it 'should batch events' do
        sample_batches.each do |batch_entries|
          expect(sqs).to receive(:send_message_batch).with(:queue_url => queue_url, :entries => batch_entries)
        end

        subject.multi_receive_encoded(sample_events)
      end
    end

    context 'with empty payload' do
      let(:sample_count) { 0 }

      it 'does not raise an error' do
        expect { subject.multi_receive_encoded(sample_events) }.not_to raise_error
      end

      it 'should not send any messages' do
        expect(sqs).not_to receive(:send_message)
        expect(sqs).not_to receive(:send_message_batch)
        subject.multi_receive_encoded(sample_events)
      end
    end

    context 'with event exceeding maximum size' do
      let(:config) { super.merge('message_max_size' => message_max_size) }
      let(:message_max_size) { 1024 }

      let(:sample_count) { 1 }
      let(:sample_event) { LogStash::Event.new('message' => '.' * message_max_size) }

      it 'should drop event' do
        expect(sqs).not_to receive(:send_message)
        expect(sqs).not_to receive(:send_message_batch)
        subject.multi_receive_encoded(sample_events)
      end
    end



    context 'with large batch' do
      let(:batch_events) { 4 }
      let(:config) do
        super.merge({
          'batch_events' => batch_events,
          'message_max_size' => message_max_size,
        })
      end
      let(:message_max_size) { 1024 }

      let(:sample_events) do
        # This is the overhead associating with transmitting each message. The
        # overhead is caused by metadata (such as the `message` field name and
        # the `@timestamp` field) as well as additional characters as a result
        # of encoding the event.
        overhead = 69

        events = [
          LogStash::Event.new('message' => 'a' * (0.6 * message_max_size - overhead)),
          LogStash::Event.new('message' => 'b' * (0.5 * message_max_size - overhead)),
          LogStash::Event.new('message' => 'c' * (0.5 * message_max_size - overhead)),
          LogStash::Event.new('message' => 'd' * (0.4 * message_max_size - overhead)),
        ]

        events.map do |event|
          [event, LogStash::Json.dump(event)]
        end
      end

      let(:sample_batches) do
        [
          [
            {
              :id => '0',
              :message_body => sample_events[0][1],
            },
          ],
          [
            {
              :id => '1',
              :message_body => sample_events[1][1],
            },
            {
              :id => '2',
              :message_body => sample_events[2][1],
            },
          ],
          [
            {
              :id => '3',
              :message_body => sample_events[3][1],
            },
          ],
        ]
      end

      it 'should split events into smaller batches' do
        sample_batches.each do |entries|
          expect(sqs).to receive(:send_message_batch).with(:queue_url => queue_url, :entries => entries)
        end

        subject.multi_receive_encoded(sample_events)
      end
    end
  end
end
