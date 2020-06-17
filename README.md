# `MQTT::InfluxDB::Translator`

Translate values of subscribed MQTT topics, write values to InfluxDB database.

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'mqtt-influxdb-translator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mqtt-influxdb-translator

## Usage

```console
bundle exec ruby bin/app.rb
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
https://github.com/trombik/mqtt-influxdb-translator.

## License

The gem is available as open source under the terms of the [ISC
License](https://opensource.org/licenses/ISC).
