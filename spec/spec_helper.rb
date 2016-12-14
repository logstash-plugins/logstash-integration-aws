# encoding: utf-8

require 'aws-sdk'
require 'logstash/devutils/rspec/spec_helper'
require 'logstash/outputs/sqs'
require_relative 'supports/helpers'

LogStash::Logging::Logger::configure_logging('debug') if ENV['DEBUG']
