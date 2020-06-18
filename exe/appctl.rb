#!/usr/bin/env ruby
# frozen_string_literal: true

require "daemons"
require "pathname"
require "yaml"
require "deep_merge"
require "mqtt/influxdb/translator/version"

command = ARGV.first
app_name = "mqtt-influxdb-translator"

# XXX do not assume "/etc"
prefix = case Gem::Platform.local.os
         when "freebsd"
           "/usr/local/"
         else
           "/"
         end
config_path = ARGV[2] || Pathname.new(prefix) + \
                         "etc/#{app_name}/config.yml"
default_config = {
  "daemons" => {
    "daemonize" => true,
    "pid_dir" => Pathname.pwd.to_s
  },
  "log_level" => "DEBUG",
  "paho-mqtt" => {},
  "influxdb" => {}
}
config = default_config.deep_merge!(YAML.safe_load(File.read(config_path)))

case command
when "start"
  puts "Starting #{app_name} version #{MQTT::InfluxDB::Translator::VERSION}"
  puts config.to_yaml if config["log_level"].downcase == "debug"
end

opts = {
  app_name: app_name,
  log_output: false,
  dir: config["daemons"]["pid_dir"],
  dir_mode: :normal,
  ontop: !config["daemons"]["daemonize"]
}

Daemons.run(Pathname.new(__FILE__).dirname + "app.rb", opts)
