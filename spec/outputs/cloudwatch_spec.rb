require "logstash/devutils/rspec/spec_helper"
require "logstash/outputs/cloudwatch"

describe "outputs/cloudwatch" do
  
  let(:config) { { 'metricname' => 'foo' } }

  subject(:plugin) { LogStash::Outputs::CloudWatch.new(config) }

  it "should register" do
    expect { plugin.register }.to_not raise_error
  end

  it "should respond correctly to a receive call" do
    plugin.register
    event = LogStash::Event.new
    expect { plugin.receive(event) }.to_not raise_error
  end

  context 'with queue_size' do

    let(:queue_size) { 100 }

    let(:config) { super().merge('queue_size' => queue_size) }

    it "triggers job ahead of time" do
      plugin.register
      event_queue = plugin.event_queue
      allow( event_queue ).to receive(:length).and_return queue_size # emulate full queue
      expect( plugin ).to receive(:publish)

      event = LogStash::Event.new
      plugin.receive(event)
      sleep 1.0 # allow scheduler to kick in
    end

  end
end
