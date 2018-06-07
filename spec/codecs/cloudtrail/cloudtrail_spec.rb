require "logstash/devutils/rspec/spec_helper"
require "logstash/plugin"
require "logstash/codecs/cloudtrail"
require 'resolv'

describe LogStash::Codecs::CloudTrail do

  shared_examples_for "it handles valid ip addresses" do
    it 'should pass through valid ip addresses' do
      ip_addresses.each do |valid_ip_address|
        subject.decode("{\"Records\":[{\"sourceIpAddress\":\"#{valid_ip_address}\"}]}") do |event|
          expect(event.get("sourceIpAddress")).to eq(valid_ip_address)
          expect(event.get("sourceHost")).to be_nil
        end
      end
    end
  end

  describe '#decode' do
    it 'accepts data without a Records property' do
      expect { |b|
        subject.decode('{}', &b)
      }.not_to yield_control
    end

    it 'accepts records with null requestParameters' do
      expect { |b|
        subject.decode('{"Records":[{"requestParameters":null}]}', &b)
      }.to yield_control
    end

    context 'with ipv4 sourceIpAddress values' do
      let(:ip_addresses) { ["127.0.0.1", "8.8.8.8", "10.10.10.10", "100.100.100.100", "1.12.123.234"] }
      it_behaves_like 'it handles valid ip addresses'
    end

    context 'with ipv6 sourceIpAddress values' do
      let(:ip_addresses) { ["2001:0db8:85a3:0000:0000:8a2e:0370:7334", "2001:db8:85a3::8a2e:370:7334", "::1", "::"] }
      it_behaves_like 'it handles valid ip addresses'
    end

    it 'accepts records with an invalid sourceIpAddress' do
      subject.decode('{"Records":[{"sourceIpAddress":"www.elastic.co"}]}') do |event|
        expect(event.get("sourceIpAddress")).to be_nil
        expect(event.get("sourceHost")).to eq("www.elastic.co")
      end
    end

    it 'accepts records with a no sourceIpAddress' do
      subject.decode('{"Records":[{"sourceIpAddress":null}]}') do |event|
        expect(event.get("sourceIpAddress")).to be_nil
        expect(event.get("sourceHost")).to be_nil
      end
    end
  end
end
