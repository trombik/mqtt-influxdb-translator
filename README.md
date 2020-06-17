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

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/trombik/mqtt-influxdb-translator.

## License

The gem is available as open source under the terms of the [ISC
License](https://opensource.org/licenses/ISC).
