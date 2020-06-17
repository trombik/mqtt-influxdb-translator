# frozen_string_literal: true

require "mqtt/influxdb/translator/version"
require "logger"
require "paho-mqtt"
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
          @mqtt = PahoMqtt::Client.new(@opts["paho-mqtt"])
        end

        def start
          connect_influxdb
          register_mqtt_callback
          @mqtt.connect(@mqtt.host, @mqtt.port,
                        @mqtt.keep_alive,
                        @mqtt.persistent,
                        false)
          @mqtt.subscribe(@opts["topics"])
          loop { sleep 0.01 }
        end

        def register_mqtt_callback
          @mqtt.on_connack = proc do
            log(:info, "Connected to MQTT broaker", "")
          end
          @mqtt.on_message do |packet|
            write(packet.topic, packet.payload, now_in_nano_sec)
          end
        end

        def connect_influxdb
          log(:info, "Connecting to InfluxDB", "")
          log(:debug, "opts['influxdb']: %<opts>s", opts: @opts["influxdb"])
          @influxdb = ::InfluxDB::Client.new(@opts["influxdb"]
                                        .transform_keys(&:to_sym))
        end

        def write(topic, value, timestamp)
          name, data = translate(topic, value, timestamp)
          write_point(name, data)
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
          log(:debug,
              "%<topic>s %<value>s %<timestamp>s",
              topic: topic, value: value, timestamp: timestamp)
          result = [nil, nil]
          begin
            # rubocop:disable Security/Eval
            result = eval(@opts["translate"])
            # rubocop:enable Security/Eval
          rescue StandardError => e
            log(:error, e.to_s + "\n" + e.backtrace)
          end
          result
        end
      end

      class Error < StandardError; end
    end
  end
end
