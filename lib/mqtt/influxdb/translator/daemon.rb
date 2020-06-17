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
              write(c, topic, msg, now_in_nano_sec)
            end
          end
        end

        def connect_influxdb
          log(:info, "Connecting to InfluxDB", "")
          log(:debug, "opts['influxdb']: %<opts>s", opts: @opts["influxdb"])
          @influxdb = ::InfluxDB::Client.new(@opts["influxdb"]
                                        .transform_keys(&:to_sym))
        end

        def write(client, topic, value, timestamp)
          name, data = translate(client, topic, value, timestamp)
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

        def translate(client, topic, value, timestamp)
          log(:debug,
              "%<client>s %<topic>s %<value>s %<timestamp>s",
              client: client, topic: topic, value: value, timestamp: timestamp)
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
