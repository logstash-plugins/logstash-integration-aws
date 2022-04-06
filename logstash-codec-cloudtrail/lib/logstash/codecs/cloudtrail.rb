# encoding: utf-8
require "logstash/codecs/base"
require "logstash/json"
require "logstash/util/charset"

# This is the base class for logstash codecs.
class LogStash::Codecs::CloudTrail < LogStash::Codecs::Base
  config_name "cloudtrail"

  config :charset, :validate => ::Encoding.name_list, :default => "UTF-8"

  public
  def register
    @converter = LogStash::Util::Charset.new(@charset)
    @converter.logger = @logger
  end

  public
  def decode(data)
    decoded = LogStash::Json.load(@converter.convert(data))
    decoded['Records'].to_a.each do |event|
      event['@timestamp'] = event.delete('eventTime')

      if event["requestParameters"] && event['requestParameters'].has_key?("disableApiTermination")
        if event['requestParameters']['disableApiTermination'].class != Hash
          disableApiTermination = event['requestParameters'].delete('disableApiTermination')
          event['requestParameters']['disableApiTermination']= {"value" => disableApiTermination}
        end
      end

      substitute_invalid_ip_address(event)

      yield LogStash::Event.new(event)
    end
  end # def decode

  # Workaround for https://github.com/logstash-plugins/logstash-codec-cloudtrail/issues/20
  # API calls from support will fill the sourceIpAddress with a hostname string instead of an ip
  # address.
  def substitute_invalid_ip_address(event)
    source_ip_address = event["sourceIpAddress"]
    if source_ip_address && source_ip_address !~ Resolv::IPv4::Regex && source_ip_address !~ Resolv::IPv6::Regex
      event["sourceHost"] = event.delete("sourceIpAddress")
    end
  end

end # class LogStash::Codecs::CloudTrail
