# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"
require "logstash/plugin_mixins/aws_config"

# SNS output.
#
# Send events to Amazon's Simple Notification Service, a hosted pub/sub
# framework.  It supports subscribers of type email, HTTP/S, SMS, and SQS.
#
# For further documentation about the service see:
#
#   http://docs.amazonwebservices.com/sns/latest/api/
#
# This plugin looks for the following fields on events it receives:
#
#  * `sns` - If no ARN is found in the configuration file, this will be used as
#  the ARN to publish.
#  * `sns_subject` - The subject line that should be used.
#  Optional. The "%{host}" will be used if not present and truncated at
#  `MAX_SUBJECT_SIZE_IN_CHARACTERS`.
#  * `sns_message` - The message that should be
#  sent. Optional. The event serialzed as JSON will be used if not present and
#  with the @message truncated so that the length of the JSON fits in
#  `MAX_MESSAGE_SIZE_IN_BYTES`.
#
class LogStash::Outputs::Sns < LogStash::Outputs::Base
  include LogStash::PluginMixins::AwsConfig::V2

  MAX_SUBJECT_SIZE_IN_CHARACTERS  = 100
  MAX_MESSAGE_SIZE_IN_BYTES       = 32768

  config_name "sns"

  # Message format.  Defaults to plain text.
  config :format, :validate => [ "json", "plain" ], :default => "plain"

  # SNS topic ARN.
  config :arn, :validate => :string

  # When an ARN for an SNS topic is specified here, the message
  # "Logstash successfully booted" will be sent to it when this plugin
  # is registered.
  #
  # Example: arn:aws:sns:us-east-1:770975001275:logstash-testing
  #
  config :publish_boot_message_arn, :validate => :string

  public
  def register
    require "aws-sdk-resources"

    @sns = Aws::SNS::Client.new(aws_options_hash)

    publish_boot_message_arn()

    @codec.on_event do |event, encoded|
      send_sns_message(event_arn(event), event_subject(event), encoded)
    end
  end

  public
  def receive(event)
    return unless output?(event)

    if (sns_msg = Array(event["sns_message"]).first)
      send_sns_message(event_arn(event), event_subject(event), sns_msg)
    else
      @codec.encode(event)
    end
  end

  private
  def publish_boot_message_arn
    # Try to publish a "Logstash booted" message to the ARN provided to
    # cause an error ASAP if the credentials are bad.
    if @publish_boot_message_arn
      @sns.topics[@publish_boot_message_arn].publish("Logstash successfully booted", :subject => "Logstash booted")
    end
  end

  private
  def send_sns_message(arn, subject, message)
    raise ArgumentError, "An SNS ARN is required." unless arn

    trunc_subj = subject.slice(0, MAX_SUBJECT_SIZE_IN_CHARACTERS)
    trunc_msg = message.slice(0, MAX_MESSAGE_SIZE_IN_BYTES)

    @logger.debug? && @logger.debug("Sending event to SNS topic [#{arn}] with subject [#{trunc_subj}] and message: #{trunc_msg}")

    @sns.publish({
                   :topic_arn => arn,
                   :subject => trunc_subj,
                   :message => trunc_msg
                 })
  end

  private
  def event_subject(event)
    Array(event["sns_subject"]).first || event["host"]
  end

  private
  def event_arn(event)
    Array(event["sns"]).first || @arn
  end
end
