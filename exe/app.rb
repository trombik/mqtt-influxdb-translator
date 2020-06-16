#!/usr/bin/env ruby
# frozen_string_literal: true

require "mqtt/influxdb/translator"
require "yaml"

config = YAML.safe_load(File.read("config/test.yml"))

daemon = MQTT::InfluxDB::Translator::Daemon.new(config)
daemon.start
