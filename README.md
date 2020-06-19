# `MQTT::InfluxDB::Translator`

Translate values of subscribed MQTT topics, write values to InfluxDB database.

## Features

- Translate published values of MQTT topics with ruby, write the translated
  data to `InfluxDB`.
- Include arbitrary values of other MQTT topics in the `InfluxDB` record (see
  `lookup_translate` and `lookup_topics`)

## Not implemented (yet)

- Startup scripts

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem "mqtt-influxdb-translator", git: "https://github.com/trombik/mqtt-influxdb-translator.git", branch: "master"
```

And then execute:

```console
> bundle
```

## Configuration

```yaml
---

influxdb:
  auth_method: basic_auth
  username: user
  password: password
  database: mydatabase
  time_precision: ns
  hosts:
    - influxdb.example.org
paho-mqtt:
  host: hab.i.trombik.org
  ssl: false
  reconnect_delay: 10
  client_id: mqtt-influxdb-translator
  persistent: true

log_level: DEBUG
log_file: /dev/null
topics:
  - ["homie/+/esp/uptime", 1]
  - ["homie/+/esp/freeheap", 1]
  - ["homie/+/esp/rssi", 1]
  - ["homie/+/esp/signal", 1]
lookup_topics:
  - ["homie/+/esp/location", 1]
translate: |
  # the translation logic, will be executed with ruby's `eval`.
  #
  # Available variables:
  #
  # * topic, MQTT topic string
  # * value, value of the topic. note that the value is always String. if the
  #   value is number, use `value.to_i`, or `value.to_f`.
  # * timestamp, nano sec when the value is fetched
  #
  # this ruby fragment must return a list of `name` and `data`.
  # they are arguments for InfluxDB#write_point. See
  # https://github.com/influxdata/influxdb-ruby
  #
  (_dummy, mac_addr, node_name, attribute_name) = topic.split("/")
  data = {
    values: { attribute_name => value.to_i },
    tags: { mac_addr: mac_addr },
    timestamp: timestamp
  }
  if @lookup.key?(mac_addr) && @lookup[mac_addr].key?("location")
    data[:tags][:location] = @lookup[mac_addr]["location"]
  end
  return [node_name, data]

lookup_translate: |
  (_dummy, mac_addr, node_name, attribute_name) = topic.split("/")
  @lookup[mac_addr] = { attribute_name => value }
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

### `lookup_translate`, and `lookup_topics`

`lookup_topics` is a list of optional MQTT topics to subscribe. The values of
the topics will not be sent to `InfluxDB`.

`lookup_translate` is ruby code to translate `lookup_topics` and values for
lookup in `translate`.  When a value of the topics is published,
`lookup_translate` will be executed.  Available variables are same as in
`translate`.

In `lookup_translate`, use `@lookup` instance variable to keep some values for
lookup in `translate`.

An example: you want to monitor a value of an MQTT topic.

```console
homie/aabbccddeeff/esp/signal: 75
```

Also, your device publishes another MQTT topic, `location`.

```console
homie/aabbccddeeff/esp/location: "somewhere"
```

You want to include a tag in `InfluxDB` record, `location=somewhere`, so that
you can see not only MAC address of the device, but also the location of the
device, which is more useful for humans. But, in `translate`, what you have is
MQTT topic, its value, and time only. With `lookup_topics` and
`lookup_translate`, you can lookup the location of the device with MAC address
as a key. See the following example.

```yaml
---
topics:
  - ["homie/+/esp/uptime", 1]
  - ["homie/+/esp/freeheap", 1]
  - ["homie/+/esp/rssi", 1]
  - ["homie/+/esp/signal", 1]
lookup_topics:
  - ["homie/+/esp/location", 1]
translate: |
  (_dummy, mac_addr, node_name, attribute_name) = topic.split("/")
  data = {
    values: { attribute_name => value.to_i },
    tags: { mac_addr: mac_addr },
    timestamp: timestamp
  }
  if @lookup.key?(mac_addr) && @lookup[mac_addr].key?("location")
    data[:tags][:location] = @lookup[mac_addr]["location"]
  end
  return [node_name, data]

lookup_translate: |
  (_dummy, mac_addr, node_name, attribute_name) = topic.split("/")
  @lookup[mac_addr] = { attribute_name => value }
```

## Usage

To start the daemon, run:

```console
bundle exec ruby exe/mqitctl start -- /path/to/config.yml
```

To stop the daemon, run:

```console
bundle exec ruby exe/mqitctl stop -- /path/to/config.yml
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
