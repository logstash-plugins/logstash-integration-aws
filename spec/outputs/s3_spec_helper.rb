# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require_relative "s3/supports/helpers"
require "logstash/logging/logger"

LogStash::Logging::Logger::configure_logging("debug") if ENV["DEBUG"]
