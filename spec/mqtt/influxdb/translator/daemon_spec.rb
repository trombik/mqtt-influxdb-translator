# frozen_string_literal: true

RSpec.describe MQTT::InfluxDB::Translator::Daemon do
  let(:opts) do
    {
      "influxdb" => {
        "hosts" => ["localhost"]
      },
      "mqtt" => {
        "host" => "localhost"
      },
      "log_file" => "/dev/null"
    }
  end
  let(:obj) { MQTT::InfluxDB::Translator::Daemon.new(opts) }
  let(:topic) { "homie/A020A615E8E9/esp/signal" }
  let(:value) { 36 }
  let(:now) { 1_592_277_621_000_000_000 }

  describe ".new" do
    it "initialize the instance" do
      expect { obj }.not_to raise_error
    end
  end

  describe "#translate" do
    # HOMIE: topic `homie/A020A615E8E9/esp/signal` payload: `36`
    # esp,mac_addr=A020A615E8E9,signal=36 1592277621000000000

    it "translate MQTT value to a list of name and data" do
      name, data = obj.translate(topic, value, now)
      expect(name).to eq "esp"
      expect(data[:values].key?("signal")).to be true
      expect(data[:values]["signal"]).to eq 36
      expect(data[:tags][:mac_addr]).to eq "A020A615E8E9"
      expect(data[:timestamp]).to eq now
    end
  end
end
