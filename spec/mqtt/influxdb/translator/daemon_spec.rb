# frozen_string_literal: true

require "pathname"
require "yaml"

RSpec.describe MQTT::InfluxDB::Translator::Daemon do
  let(:opts) do
    YAML.safe_load(
      File.read(Pathname.new(__FILE__).parent.parent.parent.parent +
                "config/test.yml")
    )
  end
  let(:obj) { MQTT::InfluxDB::Translator::Daemon.new(opts) }
  let(:mac_addr) { "A020A615E8E9" }
  let(:topic) { "homie/#{mac_addr}/esp/signal" }
  let(:value) { 36 }
  let(:lookup_topic) { "homie/#{mac_addr}/esp/location" }
  let(:lookup_value) { "somewhere" }
  let(:now) { 1_592_277_621_000_000_000 }

  describe ".new" do
    it "initialize the instance" do
      expect { obj }.not_to raise_error
    end
  end

  describe "#topic_pattern_to_regex" do
    context "when pattern has +" do
      it "convert MQTT topic mattern to regex" do
        valid_topic = "homie/aabbccddeeff/esp/foo"
        pattern = "homie/+/esp/foo"
        regex = obj.topic_pattern_to_regex(pattern)

        expect(valid_topic).to match(regex)
        expect("homie/aabbccddeeff/foo/bar").not_to match(regex)
        expect("homie/aabbccddeeff/esp/bar/foo").not_to match(regex)
        expect("homie/aabbccddeeff//foo/bar").not_to match(/#{regex}/)
      end
    end

    context "when pattern has + and topic contains UTF-8 characters" do
      it "convert MQTT topic mattern to regex" do
        valid_topic = "homie/日本語/esp/foo"
        pattern = "homie/+/esp/foo"
        regex = obj.topic_pattern_to_regex(pattern)

        expect(valid_topic).to match(/#{regex}/)
        expect("homie/日本語/buz/esp/foo").not_to match(regex)
        expect("homie/日本語//buz/esp/foo").not_to match(regex)
      end
    end

    context "when pattern has #" do
      it "convert MQTT topic mattern to regex" do
        valid_topic = "homie/aabbccddeeff/esp/foo"
        pattern = "homie/#"
        regex = obj.topic_pattern_to_regex(pattern)

        expect(valid_topic).to match(/#{regex}/)
      end
    end

    context "when pattern has # and topic contains UTF-8 characters" do
      it "convert MQTT topic mattern to regex" do
        valid_topic = "homie/日本語/esp/foo"
        pattern = "homie/日本語/#"
        regex = obj.topic_pattern_to_regex(pattern)

        expect(valid_topic).to match(/#{regex}/)
        expect("homie/日本語bar/esp/foo").not_to match(/#{regex}/)
        expect("foo/日本語/esp/foo").not_to match(/#{regex}/)
      end
    end

    context "when pattern has + and #" do
      it "convert MQTT topic mattern to regex" do
        valid_topic = "homie/aabbccddeeff/esp/foo/bar"
        pattern = "homie/+/esp/#"
        regex = obj.topic_pattern_to_regex(pattern)

        expect(valid_topic).to match(/#{regex}/)
      end
    end

    context "when pattern has + and #m and topic contains UTF-8 characters" do
      it "convert MQTT topic mattern to regex" do
        valid_topic = "homie/日本語/esp/foo/bar/バズ"
        pattern = "homie/+/esp/#"
        regex = obj.topic_pattern_to_regex(pattern)

        expect(valid_topic).to match(/#{regex}/)
      end
    end
  end

  describe "#lookup_translate" do
    it "translate MQTT value, and set lookup[MAC_ADDRESS]" do
      expect do
        obj.lookup_translate(lookup_topic, lookup_value, now)
      end.not_to raise_error
      expect(obj.lookup[mac_addr]["location"]).to eq lookup_value
    end
  end

  describe "#translate" do
    # HOMIE: topic `homie/A020A615E8E9/esp/signal` payload: `36`
    # esp,mac_addr=A020A615E8E9,signal=36 1592277621000000000

    it "translate MQTT value to a list of name and data" do
      name = nil
      data = nil

      expect do
        obj.lookup_translate(lookup_topic, lookup_value, now)
      end.not_to raise_error
      expect do
        name, data = obj.translate(topic, value, now)
      end.not_to raise_error
      expect(name).to eq "esp"
      expect(data[:values].key?("signal")).to be true
      expect(data[:values]["signal"]).to eq 36
      expect(data[:tags][:mac_addr]).to eq mac_addr
      expect(data[:tags][:location]).to eq lookup_value
      expect(data[:timestamp]).to eq now
    end
  end
end
