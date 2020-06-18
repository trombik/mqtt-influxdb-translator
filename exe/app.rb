#!/usr/bin/env ruby
# frozen_string_literal: true

require "mqtt/influxdb/translator"
require "yaml"
require "pathname"

config = nil

# XXX daemons gem enforces the child process to chdir to "/". resolve all
# file path during the initialization. path might not be absolute.
Dir.chdir(ENV["PWD"]) do
  prefix = case Gem::Platform.local.os
           when "freebsd"
             "/usr/local/"
           else
             "/"
           end
  config_path = ARGV[0] || Pathname.new(prefix) + \
                           "etc/mqtt-influx-translator/config.yml"
  config = YAML.safe_load(File.read(config_path))
end

daemon = MQTT::InfluxDB::Translator::Daemon.new(config)
daemon.start
