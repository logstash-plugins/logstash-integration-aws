require "logstash/plugins/registry"
require "logstash/inputs/s3"
require "logstash/inputs/sqs"
require "logstash/outputs/cloudwatch"
require "logstash/outputs/s3"

LogStash::PLUGIN_REGISTRY.add(:input, "s3", LogStash::Inputs::S3)
LogStash::PLUGIN_REGISTRY.add(:input, "sqs", LogStash::Inputs::SQS)
LogStash::PLUGIN_REGISTRY.add(:output, "cloudwatch", LogStash::Outputs::Cloudwatch)
LogStash::PLUGIN_REGISTRY.add(:output, "s3", LogStash::Outputs::S3)