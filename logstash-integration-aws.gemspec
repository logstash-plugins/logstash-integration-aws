INTEGRATION_AWS_VERSION = File.read(File.expand_path(File.join(File.dirname(__FILE__), "VERSION"))).strip unless defined?(INTEGRATION_AWS_VERSION)

Gem::Specification.new do |s|
  s.name            = "logstash-integration-aws"
  s.version         = INTEGRATION_AWS_VERSION
  s.licenses        = ["Apache-2.0"]
  s.summary         = "Collection of Logstash plugins that integrate with AWS"
  s.description     = "This gem is a Logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/logstash-plugin install gemname. This gem is not a stand-alone program"
  s.authors         = ["Elastic"]
  s.email           = "info@elastic.co"
  s.homepage        = "http://www.elastic.co/guide/en/logstash/current/index.html"
  s.platform        = "java"
  s.metadata        = {
    "logstash_plugin" => "true",
    "logstash_group" => "integration",
    "integration_plugins" => %w(
      logstash-codec-cloudfront
      logstash-codec-cloudtrail
      logstash-input-cloudwatch
      logstash-input-s3
      logstash-input-sqs
      logstash-output-cloudwatch
      logstash-output-s3
      logstash-output-sns
      logstash-output-sqs).join(",")
  }


  s.require_paths   = ["lib", "vendor/jar-dependencies"]
  s.files           = Dir["lib/**/*","spec/**/*","*.gemspec","*.md","CONTRIBUTORS","Gemfile","LICENSE","NOTICE.TXT", "VERSION", "docs/**/*", "vendor/jar-dependencies/**/*.jar", "vendor/jar-dependencies/**/*.rb"]
  s.test_files      = s.files.grep(%r{^(test|spec|features)/})


  s.add_runtime_dependency "logstash-core-plugin-api", ">= 2.1.12", "<= 2.99"
  s.add_runtime_dependency "concurrent-ruby"
  s.add_runtime_dependency "logstash-codec-json"
  s.add_runtime_dependency "logstash-codec-plain"
  s.add_runtime_dependency "rufus-scheduler", ">= 3.0.9"
  s.add_runtime_dependency "stud", "~> 0.0.22"
  s.add_runtime_dependency "rexml"
  s.add_runtime_dependency "aws-sdk-core", "~> 3"
  s.add_runtime_dependency "aws-sdk-s3"
  s.add_runtime_dependency "aws-sdk-sqs"
  s.add_runtime_dependency "aws-sdk-sns"
  s.add_runtime_dependency "aws-sdk-cloudwatch"
  s.add_runtime_dependency "aws-sdk-cloudfront"
  s.add_runtime_dependency "aws-sdk-resourcegroups"

  s.add_development_dependency "logstash-codec-json_lines"
  s.add_development_dependency "logstash-codec-multiline"
  s.add_development_dependency "logstash-codec-json"
  s.add_development_dependency "logstash-codec-line"
  s.add_development_dependency "logstash-devutils"
  s.add_development_dependency "logstash-input-generator"
  s.add_development_dependency "timecop"
end
