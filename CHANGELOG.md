## 7.1.7
  - Remove empty temporary dirs at plugin close [#46](https://github.com/logstash-plugins/logstash-integration-aws/pull/46)

## 7.1.6
  - Clean up plugin created temporary dirs at startup [#39](https://github.com/logstash-plugins/logstash-integration-aws/pull/39)

## 7.1.5
  - Fix external documentation links [#35](https://github.com/logstash-plugins/logstash-integration-aws/pull/35)

## 7.1.4
  - Fix `use_aws_bundled_ca` to use bundled ca certs per plugin level instead of global [#33](https://github.com/logstash-plugins/logstash-integration-aws/pull/33)

## 7.1.3
  - Added an option `use_aws_bundled_ca` to use bundled ca certs that ships with AWS SDK to verify SSL peer certificates [#32](https://github.com/logstash-plugins/logstash-integration-aws/pull/32)

## 7.1.2
  - Fix: adaptations to run with JRuby 9.4 [#29](https://github.com/logstash-plugins/logstash-integration-aws/pull/29)

## 7.1.1
  - Fix: Plugin cannot load Java dependencies [#24](https://github.com/logstash-plugins/logstash-integration-aws/pull/24)

## 7.1.0
  - Plugin restores and uploads corrupted GZIP files (caused by abnormal termination) to AWS S3 [#20](https://github.com/logstash-plugins/logstash-integration-aws/pull/20)

## 7.0.1
  - resolves two closely-related race conditions in the S3 Output plugin's handling of stale temporary files that could cause plugin crashes or data-loss [#19](https://github.com/logstash-plugins/logstash-integration-aws/pull/19)
    - prevents a `No such file or directory` crash that could occur when a temporary file is accessed after it has been detected as stale (empty+old) and deleted.
    - prevents a possible deletion of a non-empty temporary file that could occur if bytes were written to it _after_ it was detected as stale (empty+old) and _before_ the deletion completed.

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
