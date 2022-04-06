# CHANGELOG - logstash-codec-cloudfront

## 3.0.3
  - Update gemspec summary

## 3.0.2
  - Fix some documentation issues

# 2.0.4
  - Depend on logstash-core-plugin-api instead of logstash-core, removing the need to mass update plugins on major releases of logstash
# 2.0.3
  - New dependency requirements for logstash-core for the 5.0 release
## 2.0.0
 - Plugins were updated to follow the new shutdown semantic, this mainly allows Logstash to instruct input plugins to terminate gracefully, 
   instead of using Thread.raise on the plugins' threads. Ref: https://github.com/elastic/logstash/pull/3895
 - Dependency on logstash-core update to 2.0

---------

# CHANGELOG - logstash-codec-cloudtrail

## 3.0.5
  - [#22](https://github.com/logstash-plugins/logstash-codec-cloudtrail/pull/22)Handle 'sourceIpAddress' fields with non-ip address content by moving them to 'sourceHost' field

## 3.0.4
  - Don't crash when data doesn't contain some particular elements

## 3.0.3
  - Fix some documentation issues

# 3.0.1
  - fixed mapping template for requestParameters.disableApiTermination field

## 3.0.0
  - Update to support Logstash 2.4 & 5.0 APIs
  
## 2.0.4
  - Depend on logstash-core-plugin-api instead of logstash-core, removing the need to mass update plugins on major releases of logstash
  
## 2.0.3
  - New dependency requirements for logstash-core for the 5.0 release
  
## 2.0.0
 - Plugins were updated to follow the new shutdown semantic, this mainly allows Logstash to instruct input plugins to terminate gracefully, 
   instead of using Thread.raise on the plugins' threads. Ref: https://github.com/elastic/logstash/pull/3895
 - Dependency on logstash-core update to 2.0

---------

# CHANGELOG - logstash-input-cloudwatch

## 2.2.4
  - Fixed shutdown handling [#43](https://github.com/logstash-plugins/logstash-input-cloudwatch/pull/43)

## 2.2.3
  - Fixed issue where metric timestamp was being lost due to over-writing by end_time [#38](https://github.com/logstash-plugins/logstash-input-cloudwatch/pull/38)

## 2.2.2
  - Added ability to use AWS/EC2 namespace without requiring filters [#36](https://github.com/logstash-plugins/logstash-input-cloudwatch/pull/36)

## 2.2.1
  - Fixed README.md link to request metric support to point to this repo [#34](https://github.com/logstash-plugins/logstash-input-cloudwatch/pull/34)

## 2.2.0
  - Changed to use the underlying version of the AWS SDK to v2. [#32](https://github.com/logstash-plugins/logstash-input-cloudwatch/pull/32)
  - Fixed License definition in gemspec to be valid SPDX identifier [#32](https://github.com/logstash-plugins/logstash-input-cloudwatch/pull/32)
  - Fixed fatal error when using secret key attribute in config [#30](https://github.com/logstash-plugins/logstash-input-cloudwatch/issues/30)

## 2.1.1
  - Docs: Set the default_codec doc attribute.

## 2.1.0
  - Add documentation for endpoint, role_arn and role_session_name #29
  - Reduce info level logging verbosity #27

## 2.0.3
  - Update gemspec summary

## 2.0.2
  - Fix some documentation issues

# 1.1.3
  - Depend on logstash-core-plugin-api instead of logstash-core, removing the need to mass update plugins on major releases of logstash
# 1.1.1
  - New dependency requirements for logstash-core for the 5.0 release
## 1.1.0
 - Moved from jrgns/logstash-input-cloudwatch to logstash-plugins

---------

# CHANGELOG - logstash-input-s3

## 3.8.4
 - Refactoring, reuse code to manage `additional_settings` from mixin-aws [#237](https://github.com/logstash-plugins/logstash-input-s3/pull/237)

## 3.8.3
 - Fix missing `metadata` and `type` of the last event [#223](https://github.com/logstash-plugins/logstash-input-s3/pull/223)

## 3.8.2
 - Refactor: read sincedb time once per bucket listing [#233](https://github.com/logstash-plugins/logstash-input-s3/pull/233)

## 3.8.1
 - Feat: cast true/false values for additional_settings [#232](https://github.com/logstash-plugins/logstash-input-s3/pull/232)

## 3.8.0
 - Add ECS v8 support.

## 3.7.0
 - Add ECS support. [#228](https://github.com/logstash-plugins/logstash-input-s3/pull/228)
 - Fix missing file in cutoff time change. [#224](https://github.com/logstash-plugins/logstash-input-s3/pull/224)

## 3.6.0
 - Fixed unprocessed file with the same `last_modified` in ingestion. [#220](https://github.com/logstash-plugins/logstash-input-s3/pull/220)

## 3.5.2
 - [DOC]Added note that only AWS S3 is supported. No other S3 compatible storage solutions are supported. [#208](https://github.com/logstash-plugins/logstash-input-s3/issues/208)

## 3.5.1
 - [DOC]Added example for `exclude_pattern` and reordered option descriptions [#204](https://github.com/logstash-plugins/logstash-input-s3/issues/204)
 
## 3.5.0
 - Added support for including objects restored from Glacier or Glacier Deep [#199](https://github.com/logstash-plugins/logstash-input-s3/issues/199)
 - Added `gzip_pattern` option, enabling more flexible determination of whether a file is gzipped [#165](https://github.com/logstash-plugins/logstash-input-s3/issues/165)
 - Refactor: log exception: class + unify logging messages a bit [#201](https://github.com/logstash-plugins/logstash-input-s3/pull/201)

## 3.4.1
 - Fixed link formatting for input type (documentation)

## 3.4.0
 - Skips objects that are archived to AWS Glacier with a helpful log message (previously they would log as matched, but then fail to load events) [#160](https://github.com/logstash-plugins/logstash-input-s3/pull/160)
 - Added `watch_for_new_files` option, enabling single-batch imports [#159](https://github.com/logstash-plugins/logstash-input-s3/pull/159)

## 3.3.7
  - Added ability to optionally include S3 object properties inside @metadata [#155](https://github.com/logstash-plugins/logstash-input-s3/pull/155)

## 3.3.6
  - Fixed error in documentation by removing illegal commas [#154](https://github.com/logstash-plugins/logstash-input-s3/pull/154)

## 3.3.5
  - [#136](https://github.com/logstash-plugins/logstash-input-s3/pull/136) Avoid plugin crashes when encountering 'bad' files in S3 buckets

## 3.3.4
  - Log entry when bucket is empty #150

## 3.3.3
  - Symbolize hash keys for additional_settings hash #148

## 3.3.2
  - Docs: Set the default_codec doc attribute.

## 3.3.1
 - Improve error handling when listing/downloading from S3 #144

## 3.3.0
  - Add documentation for endpoint, role_arn and role_session_name #142
  - Add support for additional_settings option #141

## 3.2.0
 - Add support for auto-detecting gzip files with `.gzip` extension, in addition to existing support for `*.gz`
 - Improve performance of gzip decoding by 10x by using Java's Zlib

## 3.1.9
  - Change default sincedb path to live in `{path.data}/plugins/inputs/s3` instead of $HOME.
    Prior Logstash installations (using $HOME default) are automatically migrated.
  - Don't download the file if the length is 0 #2

## 3.1.8
  - Update gemspec summary

## 3.1.7
  - Fix missing last multi-line entry #120

## 3.1.6
  - Fix some documentation issues

## 3.1.4
 - Avoid parsing non string elements #109

## 3.1.3
 - The plugin will now include the s3 key in the metadata #105

## 3.1.2
 - Fix an issue when the remote file contains multiple blob of gz in the same file #101
 - Make the integration suite run
 - Remove uneeded development dependency

## 3.1.1
  - Relax constraint on logstash-core-plugin-api to >= 1.60 <= 2.99

## 3.1.0
 - breaking,config: Remove deprecated config `credentials` and `region_endpoint`. Please use AWS mixin.

## 3.0.1
 - Republish all the gems under jruby.

## 3.0.0
 - Update the plugin to the version 2.0 of the plugin api, this change is required for Logstash 5.0 compatibility. See https://github.com/elastic/logstash/issues/5141

## 2.0.6
 - Depend on logstash-core-plugin-api instead of logstash-core, removing the need to mass update plugins on major releases of logstash

## 2.0.5
 - New dependency requirements for logstash-core for the 5.0 release

## 2.0.4
 - Fix for Error: No Such Key problem when deleting

## 2.0.3
 - Do not raise an exception if the sincedb file is empty, instead return the current time #66

## 2.0.0
 - Plugins were updated to follow the new shutdown semantic, this mainly allows Logstash to instruct input plugins to terminate gracefully, 
   instead of using Thread.raise on the plugins' threads. Ref: https://github.com/elastic/logstash/pull/3895
 - Dependency on logstash-core update to 2.0

---------

# CHANGELOG - logstash-input-sqs

## 3.3.2
  - Fix an issue that prevented timely shutdown when subscribed to an inactive queue [#65](https://github.com/logstash-plugins/logstash-input-sqs/pull/65)

## 3.3.1
  - Refactoring: used logstash-mixin-aws to leverage shared code to manage `additional_settings` [#64](https://github.com/logstash-plugins/logstash-input-sqs/pull/64)

## 3.3.0
  - Feature: Add `additional_settings` option to fine-grain configuration of AWS client [#61](https://github.com/logstash-plugins/logstash-input-sqs/pull/61)

## 3.2.0
  - Feature: Add `queue_owner_aws_account_id` parameter for cross-account queues [#60](https://github.com/logstash-plugins/logstash-input-sqs/pull/60)

## 3.1.3
  - Fix: retry networking errors (with backoff) [#57](https://github.com/logstash-plugins/logstash-input-sqs/pull/57)

## 3.1.2
  - Added support for multiple events inside same message from SQS [#48](https://github.com/logstash-plugins/logstash-input-sqs/pull/48/files) 

## 3.1.1
  - Docs: Set the default_codec doc attribute.

## 3.1.0
  - Add documentation for endpoint, role_arn and role_session_name #46
  - Fix sample IAM policy to match to match the documentation #32

## 3.0.6
  - Update gemspec summary

## 3.0.5
  - Fix some documentation issues

## 3.0.3
  - Monkey-patch the AWS-SDK to prevent "uninitialized constant" errors.

## 3.0.2
  - Relax constraint on logstash-core-plugin-api to >= 1.60 <= 2.99

## 3.0.1
  - Republish all the gems under jruby.
## 3.0.0
  - Update the plugin to the version 2.0 of the plugin api, this change is required for Logstash 5.0 compatibility. See https://github.com/elastic/logstash/issues/5141
# 2.0.5
  - Depend on logstash-core-plugin-api instead of logstash-core, removing the need to mass update plugins on major releases of logstash
# 2.0.4
  - New dependency requirements for logstash-core for the 5.0 release
## 2.0.3
 - Fixes #22, wrong key use on the stats object
## 2.0.0
 - Plugins were updated to follow the new shutdown semantic, this mainly allows Logstash to instruct input plugins to terminate gracefully, 
   instead of using Thread.raise on the plugins' threads. Ref: https://github.com/elastic/logstash/pull/3895
 - Dependency on logstash-core update to 2.0

# 1.1.0
- AWS ruby SDK v2 upgrade
- Replaces aws-sdk dependencies with mixin-aws
- Removes unnecessary de-allocation
- Move the code into smaller methods to allow easier mocking and testing
- Add the option to configure polling frequency
- Adding a monkey patch to make sure `LogStash::ShutdownSignal` doesn't get catch by AWS RetryError.

---------

# CHANGELOG - logstash-mixin-aws

## 5.1.0
  - Add support for 'addition_settings' configuration options used by S3 and SQS input plugins [#53](https://github.com/logstash-plugins/logstash-mixin-aws/pull/53).

## 5.0.0
  - Drop support for aws-sdk-v1

## 4.4.1
  -  Fix: proxy with assumed role (properly) [#50](https://github.com/logstash-plugins/logstash-mixin-aws/pull/50).

## 4.4.0
  -  Fix: credentials/proxy with assumed role [#48](https://github.com/logstash-plugins/logstash-mixin-aws/pull/48).
     Plugin no longer assumes `access_key_id`/`secret_access_key` credentials not to be set when `role_arn` specified.

## 4.3.0
  - Drop strict value validation for region option #36
  - Add endpoint option to customize the endpoint uri #32
  - Allow user to provide a role to assume #27
  - Update aws-sdk dependency to '~> 2'

## 4.2.4
  - Minor config validation fixes

## 4.2.3
  - Fix some documentation issues

## 4.2.1
  - Add eu-west-2, us-east-2 and ca-central-1 regions

## 4.2.0
  - Add region ap-south-1

## 4.1.0
  - Update aws-sdk to ~> 2.3.0

## 4.0.2
  - Relax constraint on logstash-core-plugin-api to >= 1.60 <= 2.99

## 4.0.1
  - Republish all the gems under jruby.
## 4.0.0
  - Update the plugin to the version 2.0 of the plugin api, this change is required for Logstash 5.0 compatibility. See https://github.com/elastic/logstash/issues/5141
# 2.0.4
  - Depend on logstash-core-plugin-api instead of logstash-core, removing the need to mass update plugins on major releases of logstash
# 2.0.3
  - New dependency requirements for logstash-core for the 5.0 release
## 2.0.0
 - Plugins were updated to follow the new shutdown semantic, this mainly allows Logstash to instruct input plugins to terminate gracefully, 
   instead of using Thread.raise on the plugins' threads. Ref: https://github.com/elastic/logstash/pull/3895
 - Dependency on logstash-core update to 2.0

# 1.0.1
  * Correctly set proxy options on V2 of the aws-sdk

# 1.0.0
  * Allow to use either V1 or V2 of the `AWS-SDK` in your plugins. Fixes: https://github.com/logstash-plugins/logstash-mixin-aws/issues/8

---------

# CHANGELOG - logstash-output-cloudwatch

## 3.0.10
  - Deps: unpin rufus scheduler [#20](https://github.com/logstash-plugins/logstash-output-cloudwatch/pull/20)
  - Fix: an old undefined method error which would surface with load (as queue fills up) 

## 3.0.9
  - Fix: dropped usage of SHUTDOWN event deprecated since Logstash 5.0 [#18](https://github.com/logstash-plugins/logstash-output-cloudwatch/pull/18)

## 3.0.8
  - Docs: Set the default_codec doc attribute.

## 3.0.7
  - Update gemspec summary

## 3.0.6
  - Fix some documentation issues

## 3.0.4
  - Fix some remaining uses of the old event api. blocking the use of this plugin

## 3.0.3
  - Move some log messages from info to debug to avoid noise

## 3.0.2
  - Relax constraint on logstash-core-plugin-api to >= 1.60 <= 2.99

## 3.0.1
  - Republish all the gems under jruby.
## 3.0.0
  - Update the plugin to the version 2.0 of the plugin api, this change is required for Logstash 5.0 compatibility. See https://github.com/elastic/logstash/issues/5141
# 2.0.4
  - Depend on logstash-core-plugin-api instead of logstash-core, removing the need to mass update plugins on major releases of logstash
# 2.0.3
  - New dependency requirements for logstash-core for the 5.0 release
## 2.0.0
 - Plugins were updated to follow the new shutdown semantic, this mainly allows Logstash to instruct input plugins to terminate gracefully, 
   instead of using Thread.raise on the plugins' threads. Ref: https://github.com/elastic/logstash/pull/3895
 - Dependency on logstash-core update to 2.0

---------

# CHANGELOG - logstash-output-sns

## 4.0.8
  - Feat: handle host object as subject (due ECS) [#22](https://github.com/logstash-plugins/logstash-output-sns/pull/22) 

## 4.0.7
  - Docs: Set the default_codec doc attribute.

## 4.0.6
  - Update gemspec summary

## 4.0.5
  - Fix some documentation issues

## 4.0.3
  - Mark this output as thread safe to allow concurrent connections to AWS.

## 4.0.2
  - Relax constraint on logstash-core-plugin-api to >= 1.60 <= 2.99

## 4.0.1
  - Republish all the gems under jruby.
## 4.0.0
  - Update the plugin to the version 2.0 of the plugin api, this change is required for Logstash 5.0 compatibility. See https://github.com/elastic/logstash/issues/5141
# 3.0.4
  - Depend on logstash-core-plugin-api instead of logstash-core, removing the need to mass update plugins on major releases of logstash
# 3.0.3
  - New dependency requirements for logstash-core for the 5.0 release
## 3.0.0
 - Plugins were updated to follow the new shutdown semantic, this mainly allows Logstash to instruct input plugins to terminate gracefully,
   instead of using Thread.raise on the plugins' threads. Ref: https://github.com/elastic/logstash/pull/3895
 - Dependency on logstash-core update to 2.0

# 1.0.1
  * Properly trim messages for AWS without breaking unicode byte boundaries

# 1.0.0
  * Full refactor.
  * This plugin now uses codecs for all formatting. The 'format' option has now been removed. Please use a codec.
# 0.1.5
  * If no `subject` are specified fallback to the %{host} key (https://github.com/logstash-plugins/logstash-output-sns/pull/2)
  * Migrate the SNS Api to use the AWS-SDK v2

---------

# CHANGELOG - logstash-output-sqs

## 6.0.1
 - Added missing index entry for `queue_owner_aws_account_id` [#33](https://github.com/logstash-plugins/logstash-output-sqs/pull/33)

## 6.0.0
  - Removed obsolete fields `batch` and `batch_timeout`
  - Removed workaround to JRuby bug (see more [here](https://github.com/jruby/jruby/issues/3645))

## 5.1.2
  - Added the ability to send to a different account id's queue. [#30](https://github.com/logstash-plugins/logstash-output-sqs/pull/30)

## 5.1.1
  - Docs: Set the default_codec doc attribute.

## 5.1.0
  - Add documentation for endpoint, role_arn and role_session_name #29

## 5.0.2
  - Update gemspec summary

## 5.0.1
  - Fix some documentation issues

## 5.0.0
  - Breaking: mark deprecated `batch` and `batch_timeout` options as obsolete

## 4.0.1
  - Docs: Fix doc generation issue by removing extraneous comments.

## 4.0.0
  - Add unit and integration tests.
  - Adjust the sample IAM policy in the documentation, removing actions which are not actually required by the plugin. Specifically, the following actions are not required: `sqs:ChangeMessageVisibility`, `sqs:ChangeMessageVisibilityBatch`, `sqs:GetQueueAttributes` and `sqs:ListQueues`.
  - Dynamically adjust the batch message size. SQS allows up to 10 messages to be published in a single batch, however the total size of the batch is limited to 256KiB (see [Limits in Amazon SQS](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/limits-messages.html)). This plugin will now dynamically adjust the number of events included in each batch to ensure that the total batch size does not exceed `message_max_size`. Note that any single messages which exceeds the 256KiB size limit will be dropped.
  - Move to the new concurrency model, `:shared`.
  - The `batch_timeout` parameter has been deprecated because it no longer has any effect.
  - The individual (non-batch) mode of operation (i.e. `batch => false`) has been deprecated. Batch mode is vastly more performant and we do not believe that there are any use cases which require non-batch mode. You can emulate non-batch mode by setting `batch_events => 1`, although this will call `sqs:SendMessageBatch` with a batch size of 1 rather than calling `sqs:SendMessage`.
  - The plugin now implements `#multi_receive_encoded` and no longer uses `Stud::Buffer`.
  - Update the AWS SDK to version 2.

## 3.0.2
  - Relax constraint on logstash-core-plugin-api to >= 1.60 <= 2.99

## 3.0.1
  - Republish all the gems under jruby.
## 3.0.0
  - Update the plugin to the version 2.0 of the plugin api, this change is required for Logstash 5.0 compatibility. See https://github.com/elastic/logstash/issues/5141
# 2.0.5
  - Add travis config and build status
  - Require the AWS mixin to be higher than 1.0.0
# 2.0.4
  - Depend on logstash-core-plugin-api instead of logstash-core, removing the need to mass update plugins on major releases of logstash
# 2.0.3
  - New dependency requirements for logstash-core for the 5.0 release
## 2.0.0
 - Plugins were updated to follow the new shutdown semantic, this mainly allows Logstash to instruct input plugins to terminate gracefully,
   instead of using Thread.raise on the plugins' threads. Ref: https://github.com/elastic/logstash/pull/3895
 - Dependency on logstash-core update to 2.0

# CHANGELOG - logstash - output-s3

## 4.3.5
  -  Feat: cast true/false values for additional_settings [#241](https://github.com/logstash-plugins/logstash-output-s3/pull/241)

## 4.3.4
  -  [DOC] Added note about performance implications of interpolated strings in prefixes [#233](https://github.com/logstash-plugins/logstash-output-s3/pull/233)

## 4.3.3
  -  [DOC] Updated links to use shared attributes [#230](https://github.com/logstash-plugins/logstash-output-s3/pull/230)

## 4.3.2
  -  [DOC] Added note that only AWS S3 is supported. No other S3 compatible storage solutions are supported. [#223](https://github.com/logstash-plugins/logstash-output-s3/pull/223)

## 4.3.1
  -  [DOC] Updated setting descriptions for clarity [#219](https://github.com/logstash-plugins/logstash-output-s3/pull/219) and [#220](https://github.com/logstash-plugins/logstash-output-s3/pull/220)

## 4.3.0
  -  Feat: Added retry_count and retry_delay config [#218](https://github.com/logstash-plugins/logstash-output-s3/pull/218)

## 4.2.0
  - Added ability to specify [ONEZONE_IA](https://aws.amazon.com/s3/storage-classes/#__) as storage_class

## 4.1.10
  - Added clarification for endpoint in documentation [#198](https://github.com/logstash-plugins/logstash-output-s3/pull/198)

## 4.1.9
  - Added configuration information for multiple s3 outputs to documentation [#196](https://github.com/logstash-plugins/logstash-output-s3/pull/196)
  - Fixed formatting problems and typographical errors [#194](https://github.com/logstash-plugins/logstash-output-s3/pull/194), [#201](https://github.com/logstash-plugins/logstash-output-s3/pull/201), and [#204](https://github.com/logstash-plugins/logstash-output-s3/pull/204)

## 4.1.8
  - Add support for setting mutipart upload threshold [#202](https://github.com/logstash-plugins/logstash-output-s3/pull/202)

## 4.1.7
  - Fixed issue where on restart, 0 byte files could erroneously be uploaded to s3 [#195](https://github.com/logstash-plugins/logstash-output-s3/issues/195)

## 4.1.6
  - Fixed leak of file handles that prevented temporary files from being cleaned up before pipeline restart [#190](https://github.com/logstash-plugins/logstash-output-s3/issues/190)

## 4.1.5
  - Fixed bucket validation failures when bucket policy requires encryption [#191](https://github.com/logstash-plugins/logstash-output-s3/pull/191)

## 4.1.4
  - [#185](https://github.com/logstash-plugins/logstash-output-s3/pull/184) Internal: Revert rake pinning to fix upstream builds

## 4.1.3
  - [#181](https://github.com/logstash-plugins/logstash-output-s3/pull/181) Docs: Fix incorrect characterization of parameters as `required` in example configuration.
  - [#184](https://github.com/logstash-plugins/logstash-output-s3/pull/184) Internal: Pin rake version for jruby-1.7 compatibility

## 4.1.2
  - Symbolize hash keys for additional_settings hash #179

## 4.1.1
  - Docs: Set the default_codec doc attribute.

## 4.1.0
  - Add documentation for endpoint, role_arn and role_session_name #174
  - Add option for additional settings #173
  - Add more S3 bucket ACLs #158
  - Handle file not found exception on S3 upload #144
  - Document prefix interpolation #154

## 4.0.13
  - Update gemspec summary

## 4.0.12
 - Fix bug where output would fail if the s3 bucket had encryption enabled (#146, #155)

## 4.0.11
 - Fixed a randomly occurring error that logged as a missing `__jcreate_meta` method

## 4.0.10
  - Fix some documentation issues

## 4.0.9
 - Correct issue that allows to run on Ruby 9k. #150

## 4.0.8
 - Documentation changes

## 4.0.7
  - Fix: `#restore_from_crash` should use the same upload options as the normal uploader. #140
  - Fix: Wrongly named `canned_acl` options, renamed to "public-read", "public-read-write", "authenticated-read", from the documentation http://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl

## 4.0.6
  - Fix: Use the right `signature_version` for the SDK v2 #129
  - Fix an issue to prevent the output to upload empty file to S3 #128
  - Docs: Update the doc to show the new format of the remote file #126

## 4.0.5
  - Delete the file on disk after they are succesfully uploaded to S3 #122 #120
  - Added logging when an exception occur in the Uploader's `on_complete` callback

## 4.0.4
  - Add support for `storage_class` configuration
  - Fix compatibility with Logstash 2.4
  - Add support for `aws:kms` server side encryption #104

## 4.0.3
  - When configuring the `canned_acl` options of the plugins the role was not applied correctly to the created object: #7

## 4.0.2
  - Fixed AWS authentication when using instance profile credentials.

## 4.0.1
  - Improved Error logging for S3 validation. Now specific S3 perms errors are logged

## 4.0.0
  - This version is a complete rewrite over version 3.0.0 See #103
  - This Plugin now uses the V2 version of the SDK, this make sure we receive the latest updates and changes.
  - We now uses S3's `upload_file` instead of reading chunks, this method is more efficient and will uses the multipart with threads if the files is too big.
  - You can now use the `fieldref` syntax in the prefix to dynamically changes the target with the events it receives.
  - The Upload queue is now a bounded list, this options is necessary to allow back pressure to be communicated back to the pipeline but its configurable by the user.
  - If the queue is full the plugin will start the upload in the current thread.
  - The plugin now threadsafe and support the concurrency model `shared`
  - The rotation strategy can be selected, the recommended is `size_and_time` that will check for both the configured limits (`size` and `time` are also available)
  - The `restore` option will now use a separate threadpool with an unbounded queue
  - The `restore` option will not block the launch of logstash and will uses less resources than the real time path
  - The plugin now uses `multi_receive_encode`, this will optimize the writes to the files
  - rotate operation are now batched to reduce the number of IO calls.
  - Empty file will not be uploaded by any rotation rotation strategy
  - We now use Concurrent-Ruby for the implementation of the java executor
  - If you have finer grain permission on prefixes or want faster boot, you can disable the credentials check with `validate_credentials_on_root_bucket`
  - The credentials check will no longer fails if we can't delete the file
  - We now have a full suite of integration test for all the defined rotation

Fixes: #4 #81 #44 #59 #50

## 3.2.0
  - Move to the new concurrency model `:single`
  - use correct license identifier #99
  - add support for `bucket_owner_full_control` in the canned ACL #87
  - delete the test file but ignore any errors, because we actually only need to be able to write to S3. #97

## 3.1.2
  - Fix improper shutdown of output worker threads
  - improve exception handling

## 3.0.1
 - Republish all the gems under jruby.

## 3.0.0
 - Update the plugin to the version 2.0 of the plugin api, this change is required for Logstash 5.0 compatibility. See https://github.com/elastic/logstash/issues/5141

## 2.0.7
 - Depend on logstash-core-plugin-api instead of logstash-core, removing the need to mass update plugins on major releases of logstash

## 2.0.6
 - New dependency requirements for logstash-core for the 5.0 release

## 2.0.5
 - Support signature_version option for v4 S3 keys

## 2.0.4
 - Remove the `Time.now` stub in the spec, it was conflicting with other test when running inside the default plugins test #63
 - Make the spec run faster by adjusting the values of time rotation test.

## 2.0.3
 - Update deps for logstash 2.0

## 2.0.2
 - Fixes an issue when tags were defined #39

## 2.0.0
 - Plugins were updated to follow the new shutdown semantic, this mainly allows Logstash to instruct input plugins to terminate gracefully,
   instead of using Thread.raise on the plugins' threads. Ref: https://github.com/elastic/logstash/pull/3895
 - Dependency on logstash-core update to 2.0

## 1.0.1
- Fix a synchronization issue when doing file rotation and checking the size of the current file
- Fix an issue with synchronization when shutting down the plugin and closing the current temp file
