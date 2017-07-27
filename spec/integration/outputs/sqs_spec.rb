# encoding: utf-8

require_relative '../../spec_helper'
require 'logstash/event'
require 'logstash/json'
require 'securerandom'

describe LogStash::Outputs::SQS, :integration => true do
  let(:config) do
    {
      'queue' => @queue_name,
    }
  end
  subject { described_class.new(config) }

  # Create an SQS queue with a random name.
  before(:all) do
    @sqs = Aws::SQS::Client.new
    @queue_name = "logstash-output-sqs-#{SecureRandom.hex}"
    @queue_url = @sqs.create_queue(:queue_name => @queue_name)[:queue_url]
  end

  # Destroy the SQS queue which was created in `before(:all)`.
  after(:all) do
    @sqs.delete_queue(:queue_url => @queue_url)
  end

  describe '#register' do
    context 'with invalid credentials' do
      let(:config) do
        super.merge({
          'access_key_id' => 'bad_access',
          'secret_access_key' => 'bad_secret_key',
        })
      end

      it 'raises a configuration error' do
        expect { subject.register }.to raise_error(LogStash::ConfigurationError)
      end
    end

    context 'with a nonexistent queue' do
      let(:config) { super.merge('queue' => 'nonexistent-queue') }

      it 'raises a configuration error' do
        expect { subject.register }.to raise_error(LogStash::ConfigurationError)
      end
    end

    context 'with valid configuration' do
      it 'does not raise an error' do
        expect { subject.register }.not_to raise_error
      end
    end
  end

  describe '#multi_receive_encoded' do
    let(:sample_count) { 10 }
    let(:sample_event) { LogStash::Event.new('message' => 'This is a message') }
    let(:sample_events) do
      sample_count.times.map do
        [sample_event, LogStash::Json.dump(sample_event)]
      end
    end

    before do
      subject.register
    end

    after do
      subject.close
    end

    context 'with batching disabled' do
      let(:config) { super.merge('batch_events' => 1) }

      it 'publishes to SQS' do
        subject.multi_receive_encoded(sample_events)
        expect(receive_all_messages(@queue_url).count).to eq(sample_events.count)
      end
    end

    context 'with batching enabled (default)' do
      it 'publishes to SQS' do
        subject.multi_receive_encoded(sample_events)
        expect(receive_all_messages(@queue_url).count).to eq(sample_events.count)
      end
    end
  end
end
