#!/usr/bin/env ruby
# frozen_string_literal: true

require "mqtt/influxdb/translator"
require "yaml"
require "pathname"

prefix = case Gem::Platform.local.os
         when "freebsd"
           "/usr/local/"
         else
           "/"
         end

config_path = ARGV.first || Pathname.new(prefix) + \
                            "etc/mqtt-influx-translator/config.yml"
config = YAML.safe_load(File.read(config_path))

daemon = MQTT::InfluxDB::Translator::Daemon.new(config)
daemon.start
