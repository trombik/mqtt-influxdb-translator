# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mqtt/influxdb/translator/version"

Gem::Specification.new do |spec|
  spec.name          = "mqtt-influxdb-translator"
  spec.version       = MQTT::InfluxDB::Translator::VERSION
  spec.authors       = ["Tomoyuki Sakurai"]
  spec.email         = ["y@trombik.org"]

  spec.summary       = "Subscribe to MQTT topics, translate values, write them to influxdb"
  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/trombik/mqtt-influxdb-translator"
  spec.license       = "ISC"

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "influxdb", "~> 0.5.0"
  spec.add_runtime_dependency "paho-mqtt", "~> 1.0.12"
  spec.add_runtime_dependency "daemons", "~> 1.3.1"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.82.0"
end
