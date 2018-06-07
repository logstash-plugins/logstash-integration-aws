require "logstash/plugins/registry"
require "logstash/codecs/cloudfront"
require "logstash/codecs/cloudtrail"
require "logstash/inputs/cloudwatch"
require "logstash/inputs/s3"
require "logstash/inputs/sqs"
require "logstash/outputs/cloudwatch"
require "logstash/outputs/s3"
require "logstash/outputs/sns"
require "logstash/outputs/sqs"

LogStash::PLUGIN_REGISTRY.add(:codec, "cloudfront", LogStash::Codecs::Cloudfront)
LogStash::PLUGIN_REGISTRY.add(:codec, "cloudtrail", LogStash::Codecs::CloudTrail)
LogStash::PLUGIN_REGISTRY.add(:input, "cloudwatch", LogStash::Inputs::Cloudwatch)
LogStash::PLUGIN_REGISTRY.add(:input, "s3", LogStash::Inputs::S3)
LogStash::PLUGIN_REGISTRY.add(:input, "sqs", LogStash::Inputs::SQS)
LogStash::PLUGIN_REGISTRY.add(:output, "cloudwatch", LogStash::Outputs::Cloudwatch)
LogStash::PLUGIN_REGISTRY.add(:output, "s3", LogStash::Outputs::S3)
LogStash::PLUGIN_REGISTRY.add(:output, "sns", LogStash::Outputs::Sns)
LogStash::PLUGIN_REGISTRY.add(:output, "sqs", LogStash::Outputs::SQS)
