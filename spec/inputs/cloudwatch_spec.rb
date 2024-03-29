require 'logstash/devutils/rspec/spec_helper'
require 'logstash/devutils/rspec/shared_examples'
require 'logstash/inputs/cloudwatch'

describe LogStash::Inputs::CloudWatch do
  subject { LogStash::Inputs::CloudWatch.new(config) }
  let(:config) {
    {
        'access_key_id' => '1234',
        'secret_access_key' => 'secret',
        'metrics' => [ 'CPUUtilization' ],
        'region' => 'us-east-1'
    }
  }


  before do
    Aws.config[:stub_responses] = true
    Thread.abort_on_exception = true
  end

  shared_examples_for 'it requires filters' do
    context 'without filters' do
      it "raises an error" do
        expect { subject.register }.to raise_error(StandardError)
      end
    end

    context 'with filters' do
      let (:config) { super().merge('filters' => { 'tag:Monitoring' => 'Yes' })}

      it "registers succesfully" do
        expect { subject.register }.to_not raise_error
      end
    end
  end

  shared_examples_for 'it does not require filters' do
    context 'without filters' do
      it "registers succesfully" do
        expect { subject.register }.to_not raise_error
      end
    end

    context 'with filters' do
      let (:config) { super().merge('filters' => { 'tag:Monitoring' => 'Yes' })}

      it "registers succesfully" do
        expect { subject.register }.to_not raise_error
      end
    end
  end

  describe 'shutdown' do
    let(:metrics) { double("metrics") }
    let(:config) { super().merge('namespace' => 'AWS/EC2') }

    before do
      allow(subject).to receive(:metrics_for).and_return(metrics)
      allow(metrics).to receive(:count).and_return(1)
      allow(metrics).to receive(:each).and_return(['DiskWriteBytes'])
    end

    it_behaves_like "an interruptible input plugin"
  end

  describe '#register' do

    context "EC2 namespace" do
      let(:config) { super().merge('namespace' => 'AWS/EC2') }
      it_behaves_like 'it does not require filters'
    end

    context "EBS namespace" do
      let(:config) { super().merge('namespace' => 'AWS/EBS') }
      it_behaves_like 'it requires filters'
    end

    context "RDS namespace" do
      let(:config) { super().merge('namespace' => 'AWS/RDS') }
      it_behaves_like 'it requires filters'
    end

  end
end
