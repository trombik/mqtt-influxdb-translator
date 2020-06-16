# frozen_string_literal: true

RSpec.describe MQTT::InfluxDB::Translator do
  it "has a version number" do
    expect(MQTT::InfluxDB::Translator::VERSION).not_to be nil
  end
end
