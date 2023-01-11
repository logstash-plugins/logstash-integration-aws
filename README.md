# Logstash Plugin

    [![Travis Build Status](https://travis-ci.com/logstash-plugins/logstash-integration-aws.svg)](https://travis-ci.com/logstash-plugins/logstash-integration-aws)

This is a plugin for [Logstash](https://github.com/elastic/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

## Documentation

Logstash provides infrastructure to automatically generate documentation for this plugin. We use the asciidoc format to write documentation so any comments in the source code will be first converted into asciidoc and then into html. All plugin documentation are placed under one [central location](http://www.elastic.co/guide/en/logstash/current/).

- For formatting code or config example, you can use the asciidoc `[source,ruby]` directive
- For more asciidoc formatting tips, see the excellent reference here https://github.com/elastic/docs#asciidoc-guide

## Need Help?

Need help? Try #logstash on freenode IRC or the https://discuss.elastic.co/c/logstash discussion forum.

## Developing

### 1. Plugin Development and Testing

#### Code
- To get started, you'll need JRuby with the Bundler gem installed.

- Create a new plugin or clone and existing from the GitHub [logstash-plugins](https://github.com/logstash-plugins) organization. We also provide [example plugins](https://github.com/logstash-plugins?query=example).

- Install dependencies
```sh
bundle install
```

#### Test

- Update your dependencies

```sh
bundle install
```

- Run tests

```sh
bundle exec rspec
```

### 2. Running your unpublished Plugin in Logstash

#### 2.1 Run in a local Logstash clone

- Edit Logstash `Gemfile` and add the local plugin path, for example:
```ruby
gem "logstash-filter-awesome", :path => "/your/local/logstash-filter-awesome"
```
- Install plugin
```sh
# Logstash 2.3 and higher
bin/logstash-plugin install --no-verify

# Prior to Logstash 2.3
bin/plugin install --no-verify

```
- Run Logstash with your plugin
```sh
bin/logstash -e 'filter {awesome {}}'
```
At this point any modifications to the plugin code will be applied to this local Logstash setup. After modifying the plugin, simply rerun Logstash.

#### 2.2 Run in an installed Logstash

You can use the same **2.1** method to run your plugin in an installed Logstash by editing its `Gemfile` and pointing the `:path` to your local plugin development directory or you can build the gem and install it using:

- Build your plugin gem
```sh
gem build logstash-filter-awesome.gemspec
```
- Install the plugin from the Logstash home
```sh
# Logstash 2.3 and higher
bin/logstash-plugin install --no-verify

# Prior to Logstash 2.3
bin/plugin install --no-verify

```
- Start Logstash and proceed to test the plugin

## Contributing

All contributions are welcome: ideas, patches, documentation, bug reports, complaints, and even something you drew up on a napkin.

Programming is not a required skill. Whatever you've seen about open source and maintainers or community members  saying "send patches or die" - you will not see that here.

It is more important to the community that you are able to contribute.

For more information about contributing, see the [CONTRIBUTING](https://github.com/elastic/logstash/blob/master/CONTRIBUTING.md) file.

# Logstash CloudWatch Input Plugins

Pull events from the Amazon Web Services CloudWatch API.

To use this plugin, you *must* have an AWS account, and the following policy:

```json
     {
         "Version": "2012-10-17",
         "Statement": [
             {
                 "Sid": "Stmt1444715676000",
                 "Effect": "Allow",
                 "Action": [
                     "cloudwatch:GetMetricStatistics",
                     "cloudwatch:ListMetrics"
                 ],
                 "Resource": "*"
             },
             {
                 "Sid": "Stmt1444716576170",
                 "Effect": "Allow",
                 "Action": [
                     "ec2:DescribeInstances"
                 ],
                 "Resource": "*"
             }
         ]
     }
```

See the [IAM][3] section on AWS for more details on setting up AWS identities.

## Supported Namespaces

Unfortunately it's not possible to create a "one shoe fits all" solution for fetching metrics from AWS. We need to specifically add support for every namespace. This takes time so we'll be adding support for namespaces as the requests for them come in and we get time to do it. Please check the [`metric support`][1] issues for already requested namespaces, and add your request if it's not there yet.

## Configuration

Just note that the below configuration doesn't contain the AWS API access information.
 
```ruby
     input {
       cloudwatch {
         namespace => "AWS/EC2"
         metrics => [ "CPUUtilization" ]
         filters => { "tag:Monitoring" => "Yes" }
         region => "us-east-1"
       }
     }

     input {
       cloudwatch {
         namespace => "AWS/EBS"
         metrics => ["VolumeQueueLength"]
         filters => { "tag:Monitoring" => "Yes" }
         region => "us-east-1"
       }
     }

     input {
       cloudwatch {
         namespace => "AWS/RDS"
         metrics => ["CPUUtilization", "CPUCreditUsage"]
         filters => { "EngineName" => "mysql" } # Only supports EngineName, DatabaseClass and DBInstanceIdentifier
         region => "us-east-1"
       }
     }
```

See AWS Developer Guide for more information on [namespaces and metrics][2].

[1]: https://github.com/logstash-plugins/logstash-input-cloudwatch/labels/metric%20support
[2]: http://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/aws-namespaces.html
[3]: http://aws.amazon.com/iam/

# Logstash CloudWatch Input Plugins

## Required S3 Permissions

The s3 input plugin reads from your S3 bucket, and would require the following
permissions applied to the AWS IAM Policy being used:

* `s3:ListBucket` to check if the S3 bucket exists and list objects in it.
* `s3:GetObject` to check object metadata and download objects from S3 buckets.

You might also need `s3:DeleteObject` when setting S3 input to delete on read.
And the `s3:CreateBucket` permission to create a backup bucket unless already
exists.
In addition, when `backup_to_bucket` is used, the `s3:PutObject` action is also required.

For buckets that have versioning enabled, you might need to add additional
permissions.

More information about S3 permissions can be found at -
  http://docs.aws.amazon.com/AmazonS3/latest/dev/using-with-s3-actions.html


## Running tests

If you want to run the integration test against a real bucket you need to pass
your aws credentials to the test runner or declare it in your environment.

```
AWS_REGION=us-east-1 AWS_ACCESS_KEY_ID=123 AWS_SECRET_ACCESS_KEY=secret AWS_LOGSTASH_TEST_BUCKET=mytest bundle exec rspec spec/integration/s3_spec.rb --tag integration
```
