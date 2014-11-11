# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require 'logstash/outputs/sns'
require 'logstash/event'

describe LogStash::Outputs::Sns do
  describe '#format_message' do
    it 'should allow to output to sns with empty tags' do
      event = LogStash::Event.new({ "message" => "42 is the answer" })
      expect(LogStash::Outputs::Sns.format_message(event)).to match(/Tags:\s\n/m)
    end

    it 'should allow to output to sns with a list of tags' do
      event = LogStash::Event.new({"tags" => ["elasticsearch", "logstash", "kibana"] })
      expect(LogStash::Outputs::Sns.format_message(event)).to match(/\nTags:\selasticsearch,\slogstash,\skibana\n/m)
    end
  end
end
