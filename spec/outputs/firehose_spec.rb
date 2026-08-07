require 'logstash/outputs/firehose'

describe LogStash::Outputs::Firehose do

  let(:configuration) { { "delivery_stream_name" => "test" } }
  let(:output) { LogStash::Plugin.lookup("output", "firehose").new(configuration) }

  describe "#register" do

    context "when no delivery stream specified" do
      let(:configuration) { {} }
      it "the method fails with error" do
        expect { output.register }.to raise_error(LogStash::ConfigurationError)
      end
    end

    context "when batch max count out of bounds" do
      [0, LogStash::Outputs::Firehose::RECORDS_MAX_BATCH_COUNT + 1].each do |batch_max_count|
        let(:configuration) { { "delivery_stream_name" => "test", "batch_max_count" => batch_max_count } }
        it "the method fails with error" do
          expect { output.register }.to raise_error(LogStash::ConfigurationError)
        end
      end
    end

    context "when record max size out of bounds" do
      [0, LogStash::Outputs::Firehose::RECORD_MAX_SIZE_BYTES + 1].each do |record_max_size_bytes|
        let(:configuration) { { "delivery_stream_name" => "test", "record_max_size_bytes" => record_max_size_bytes } }
        it "the method fails with error" do
          expect { output.register }.to raise_error(LogStash::ConfigurationError)
        end
      end
    end

    context "when record total max size out of bounds" do
      [0, LogStash::Outputs::Firehose::RECORD_TOTAL_MAX_SIZE_BYTES + 1].each do |record_total_max_size_bytes|
        let(:configuration) { { "delivery_stream_name" => "test", "record_total_max_size_bytes" => record_total_max_size_bytes } }
        it "the method fails with error" do
          expect { output.register }.to raise_error(LogStash::ConfigurationError)
        end
      end
    end
  end

  describe "#multi_receive_encoded" do

    context "when records empty" do
      it "does not push" do
        expect(output).not_to receive(:put_record_batch)
        output.multi_receive_encoded([])
      end
    end

    context "when record too big" do
      it "does not put" do
        output.instance_variable_set(:@record_max_size_bytes, 1)
        expect(output).not_to receive(:put_record_batch)
        output.multi_receive_encoded([[nil, "{}"]])
      end
    end

    context "when receive events" do

      event1 = "{one}"
      event2 = "{two}"
      event3 = "{three}"

      it "split batches by count" do
        output.instance_variable_set(:@batch_max_count, 2)
        expect(output).to receive(:put_record_batch).once.with([{ :data => event1 }, { :data => event2 }])
        expect(output).to receive(:put_record_batch).once.with([{ :data => event3 }])
        output.multi_receive_encoded([[nil, event1], [nil, event2], [nil, event3]])
      end

      it "split batches by size" do
        output.instance_variable_set(:@record_total_max_size_bytes, event1.bytesize + event2.bytesize)
        expect(output).to receive(:put_record_batch).once.with([{ :data => event1 }, { :data => event2 }])
        expect(output).to receive(:put_record_batch).once.with([{ :data => event3 }])
        output.multi_receive_encoded([[nil, event1], [nil, event2], [nil, event3]])
      end
    end

  end

  describe "#put_record_batch" do

    let(:firehose_double) { instance_double(Aws::Firehose::Client) }

    before do
      allow(Aws::Firehose::Client).to receive(:new).and_return(firehose_double)
      output.register
    end

    context "when records empty" do
      it "does not push" do
        expect(firehose_double).not_to receive(:put_record_batch)
        output.put_record_batch([])
      end
    end

    context "when firehose throw exception" do
      it "retry" do
        expect(firehose_double).to receive(:put_record_batch).twice.and_invoke(
          proc { |_| raise RuntimeError.new('Put failed') },
          proc { |_| Aws::Firehose::Types::PutRecordBatchOutput.new }
        )
        output.put_record_batch(["test_record"])
      end
    end
  end
end