# encoding: utf-8

require 'logstash/devutils/rspec/spec_helper'
require 'logstash/outputs/sqs'
require 'logstash/logging/logger'
require_relative 'support/helpers'

LogStash::Logging::Logger::configure_logging("debug") if ENV["DEBUG"]
