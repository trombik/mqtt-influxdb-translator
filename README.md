# `MQTT::InfluxDB::Translator`

Translate values of subscribed MQTT topics, write values to InfluxDB database.

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'mqtt-influxdb-translator'
```

And then execute:

```console
> bundle
```

Or install it yourself as:

```console
> gem install mqtt-influxdb-translator
```

## Configuration

```yaml
---
daemons:
  daemonize: true
influxdb:
  auth_method: basic_auth
  username: my_user
  password: my_password
  database: my_database
  time_precision: ns
  hosts:
    - influxdb.example.org
paho-mqtt:
  host: mqtt.example.org
  ssl: false
  reconnect_delay: 10
  client_id: mqtt-influxdb-translator
  persistent: true

log_level: DEBUG
topics:
  - ["homie/+/esp/uptime", 1]
  - ["homie/+/esp/freeheap", 1]
  - ["homie/+/esp/rssi", 1]
  - ["homie/+/esp/signal", 1]
translate: |
  (_dummy, mac_addr, node_name, attribute_name) = topic.split("/")
  case attribute_name
  when "location"
    data = {
      values: { attribute_name => value },
      tags: { mac_addr: mac_addr },
      timestamp: timestamp
    }
  else
    data = {
      values: { attribute_name => value.to_i },
      tags: { mac_addr: mac_addr },
      timestamp: timestamp
    }
  end
  return [node_name, data]
```

### `daemons`

| Key | Description | Default |
|-----|-------------|---------|
| `daemonize` | `bool`. If true, daemonize. If false, run in foreground. | `true` |
| `pid_dir` | Path to `PID` file directory | current directory |

### `influxdb`

The hash is passed to `InfluxDB::Client`. See
[https://github.com/influxdata/influxdb-ruby](https://github.com/influxdata/influxdb-ruby)
for possible options.

### `paho-mqtt`

The hash is passed to `PahoMqtt::Client`. See
[https://github.com/RubyDevInc/paho.mqtt.ruby](https://github.com/RubyDevInc/paho.mqtt.ruby)
for possible options.

### `log_level`

Log level. One of accepted values by `Logger` class, such as `DEBUG`, and `INFO`.

### `translate`

The ruby code to translate MQTT topic and value. Available variables are:

- `topic`, MQTT topic string
- `value`, value of the topic. Note that the value is always `String`. If the
   value is number, use `value.to_i`, or `value.to_f`.
- `timestamp`, nano sec when the value is fetched

## Usage

To start the daemon, run:

```console
bundle exec ruby exe/appctl.rb start -- /path/to/config.yml
```

To stop the daemon, run:

```console
bundle exec ruby exe/appctl.rb stop -- /path/to/config.yml
```

## Development

### Requirements

- `ruby` 2.5.x and newer
- `bundler` 2.x
- `npm`

After checking out the repo, run `bin/setup` to install dependencies. Then,
run `rake spec` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

### Remove retained `MQTT` topics

During the development, you might need to remove obsolete, retained MQTT
topics. Use `mqtt-forget` to remove topics.

```console
node_modules/mqtt-forget/index.js -u mqtt://mqtt.example.org -f -t 'homie/${MAC_ADDRESS}/#'
```

### Remove `roomPing` device from `InfluxDB`

Run `influx`

```console
influx -precision rfc3339 -database $MYDATABSE -username $USERNAME -password $PASSWORD -host influxdb.example.org
```

Run `InfluxQL` command.

```console
DELETE FROM esp WHERE mac_addr = '$MAC_ADDRESS'
```

## Contributing

Bug reports and pull requests are welcome on GitHub at
[https://github.com/trombik/mqtt-influxdb-translator](https://github.com/trombik/mqtt-influxdb-translator).

## License

The gem is available as open source under the terms of the [ISC
License](https://opensource.org/licenses/ISC).
