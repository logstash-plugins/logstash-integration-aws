# 1.0.0
  * Full refactor. 
  * This plugin now uses codecs for all formatting. The 'format' option has now been removed. Please use a codec.
# 0.1.5
  * If no `subject` are specified fallback to the %{host} key (https://github.com/logstash-plugins/logstash-output-sns/pull/2)
  * Migrate the SNS Api to use the AWS-SDK v2
