## 7.0.0
  - bump integration to upper bound of all underlying plugins versions (biggest is sqs output 6.x)
  - this is necessary to facilitate versioning continuity between older standalone plugins and plugins within the integration

## 0.1.1
  - remove mention of mixin in gemspec to facilitate docs publishing

## 0.1.0

* Added the initial set of Logstash AWS plugins that ship with Logstash.
  You can find the merged changelog of the individual plugins in CHANGELOG.PRE.MERGE.md.
  These are (along with the version that was used for import):
  - logstash-codec-cloudfront (3.0.3) [[link]](CHANGELOG.PRE.MERGE.md#changelog---logstash-input-cloudwatch)
  - logstash-codec-cloudtrail (3.0.5) [[link]](CHANGELOG.PRE.MERGE.md#changelog---logstash-codec-cloudtrail)
  - logstash-input-cloudwatch (2.2.4) [[link]](CHANGELOG.PRE.MERGE.md#changelog---logstash-input-cloudwatch)
  - logstash-input-s3 (3.8.4) [[link]](CHANGELOG.PRE.MERGE.md#changelog---logstash-input-s3)
  - logstash-input-sqs (3.3.2) [[link]](CHANGELOG.PRE.MERGE.md#changelog---logstash-input-sqs)
  - logstash-mixin-aws (5.1.0) [[link]](CHANGELOG.PRE.MERGE.md#changelog---logstash-mixin-aws)
  - logstash-output-cloudwatch (3.0.10) [[link]](CHANGELOG.PRE.MERGE.md#changelog---logstash-output-cloudwatch)
  - logstash-output-sns (4.0.8) [[link]](CHANGELOG.PRE.MERGE.md#changelog---logstash-output-sns)
  - logstash-output-sqs (6.0.1) [[link]](CHANGELOG.PRE.MERGE.md#changelog---logstash-output-sqs)
  - logstash-output-s3 (4.3.5) [[link]](CHANGELOG.PRE.MERGE.md#changelog---logstash-output-s3)
