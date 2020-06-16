# frozen_string_literal: true

require "mqtt/influxdb/translator/version"
require "logger"
require "mqtt"
require "influxdb"

module MQTT
  module InfluxDB
    module Translator
      # The translate daemon
      class Daemon
        attr_accessor :pid, :influxdb, :opts
        def initialize(opts)
          @opts = opts
          @logger = Logger.new(@opts["log_file"] || STDOUT)
          @logger.progname = self.class
          log(:info, "version %<version>s",
              version: MQTT::InfluxDB::Translator::VERSION)
        end

        def start
          connect_influxdb
          log(:info, "Connecting to MQTT server", "")
          log(:debug, "mqtt: `%<mqtt>s`", mqtt: @opts["mqtt"])
          MQTT::Client.connect(@opts["mqtt"].transform_keys(&:to_sym)) do |c|
            log(:debug, "Subscribing to %<topics>s", topics: @opts["topics"])
            c.subscribe(@opts["topics"])
            c.get do |topic, msg|
              write(topic, msg, now_in_nano_sec)
            end
          end
        end

        def connect_influxdb
          log(:info, "Connecting to InfluxDB", "")
          log(:debug, "opts['influxdb']: %<opts>s", opts: @opts["influxdb"])
          @influxdb = ::InfluxDB::Client.new(@opts["influxdb"]
                                        .transform_keys(&:to_sym))
        end

        def write(topic, value, timestamp)
          node_name, data = translate(topic, value, timestamp)
          write_point(node_name, data)
        end

        def write_point(name, data)
          log(:debug,
              "write_point: name: `%<name>s`, data: `%<data>s`",
              { name: name, data: data })
          influxdb.write_point(name, data)
        end

        def log(level, msg, args)
          @logger.send(level.to_sym, format(msg, args))
        end

        def now_in_nano_sec
          now = Time.now.to_f * (10**9)
          now.to_i
        end

        def translate(topic, value, timestamp)
          (_dummy, mac_addr, node_name, attribute_name) = topic.split("/")
          data = {
            values: { attribute_name => value },
            tags: { mac_addr: mac_addr },
            timestamp: timestamp
          }
          [node_name, data]
        end
      end

      class Error < StandardError; end
    end
  end
end
