# frozen_string_literal: true

require "rails_helper"

RSpec.describe IntentClassifier do
  describe ".call" do
    context "with function calls present" do
      it "classifies as lead_intake when capture_lead function exists" do
        call_payload = {
          "functionCalls" => [
            {
              "name" => "capture_lead",
              "parameters" => { "name" => "John" }
            }
          ]
        }

        result = described_class.call(call_payload)
        expect(result).to eq("lead_intake")
      end

      it "classifies as scheduling when offer_times function exists" do
        call_payload = {
          "functionCalls" => [
            {
              "name" => "offer_times",
              "parameters" => { "times" => [ "Mon 2pm" ] }
            }
          ]
        }

        result = described_class.call(call_payload)
        expect(result).to eq("scheduling")
      end

      it "prefers function classification over transcript keywords" do
        call_payload = {
          "functionCalls" => [
            { "name" => "capture_lead" }
          ],
          "transcript" => [
            { "message" => "I want to book an appointment" }
          ]
        }

        result = described_class.call(call_payload)
        expect(result).to eq("lead_intake") # Function call wins
      end
    end

    context "with transcript fallback" do
      it "classifies as scheduling for booking keywords" do
        call_payload = {
          "transcript" => [
            { "message" => "I'd like to book an appointment" }
          ]
        }

        result = described_class.call(call_payload)
        expect(result).to eq("scheduling")
      end

      it "classifies as scheduling for appointment keyword" do
        call_payload = {
          "transcript" => [
            { "message" => "Can we schedule an appointment?" }
          ]
        }

        result = described_class.call(call_payload)
        expect(result).to eq("scheduling")
      end

      it "classifies as lead_intake for interested keyword" do
        call_payload = {
          "transcript" => [
            { "message" => "I'm interested in your services" }
          ]
        }

        result = described_class.call(call_payload)
        expect(result).to eq("lead_intake")
      end

      it "classifies as lead_intake for join keyword" do
        call_payload = {
          "transcript" => [
            { "message" => "I'd like to join your membership" }
          ]
        }

        result = described_class.call(call_payload)
        expect(result).to eq("lead_intake")
      end

      it "handles transcript as array of message hashes" do
        call_payload = {
          "transcript" => [
            { "message" => "Hello" },
            { "message" => "I want to book" },
            { "message" => "an appointment" }
          ]
        }

        result = described_class.call(call_payload)
        expect(result).to eq("scheduling")
      end

      it "handles case-insensitive matching" do
        call_payload = {
          "transcript" => [
            { "message" => "I'd like to BOOK an APPOINTMENT" }
          ]
        }

        result = described_class.call(call_payload)
        expect(result).to eq("scheduling")
      end

      it "handles nil messages gracefully" do
        call_payload = {
          "transcript" => [
            { "message" => "Hello" },
            { "message" => nil },
            { "message" => "book appointment" }
          ]
        }

        result = described_class.call(call_payload)
        expect(result).to eq("scheduling")
      end
    end

    context "with default fallback" do
      it "returns provided default_slug when no matches" do
        call_payload = {
          "transcript" => [ { "message" => "Hello how are you" } ]
        }

        result = described_class.call(call_payload, "custom_intent")
        expect(result).to eq("custom_intent")
      end

      it "returns 'info' when no default_slug provided" do
        call_payload = {
          "transcript" => [ { "message" => "Hello how are you" } ]
        }

        result = described_class.call(call_payload)
        expect(result).to eq("info")
      end

      it "handles empty payload gracefully" do
        result = described_class.call({})
        expect(result).to eq("info")
      end

      it "handles nil payload gracefully" do
        result = described_class.call(nil)
        expect(result).to eq("info")
      end
    end

    context "with indifferent access" do
      it "works with string keys" do
        call_payload = {
          "functionCalls" => [
            { "name" => "capture_lead" }
          ]
        }

        result = described_class.call(call_payload)
        expect(result).to eq("lead_intake")
      end

      it "works with symbol keys" do
        call_payload = {
          functionCalls: [
            { name: "capture_lead" }
          ]
        }

        result = described_class.call(call_payload)
        expect(result).to eq("lead_intake")
      end

      it "works with mixed keys" do
        call_payload = {
          functionCalls: [
            { "name" => "offer_times" }
          ]
        }

        result = described_class.call(call_payload)
        expect(result).to eq("scheduling")
      end
    end

    context "with multiple function calls" do
      it "classifies based on first matching function" do
        call_payload = {
          "functionCalls" => [
            { "name" => "capture_lead" },
            { "name" => "offer_times" }
          ]
        }

        result = described_class.call(call_payload)
        expect(result).to eq("lead_intake") # First match wins
      end
    end

    context "with empty function calls array" do
      it "falls back to transcript" do
        call_payload = {
          "functionCalls" => [],
          "transcript" => [ { "message" => "I want to book" } ]
        }

        result = described_class.call(call_payload)
        expect(result).to eq("scheduling")
      end
    end

    context "with blank transcript" do
      it "returns info when transcript is empty array" do
        call_payload = {
          "transcript" => []
        }

        result = described_class.call(call_payload)
        expect(result).to eq("info")
      end

      it "returns info when transcript has only empty messages" do
        call_payload = {
          "transcript" => [
            { "message" => "" },
            { "message" => "   " }
          ]
        }

        result = described_class.call(call_payload)
        expect(result).to eq("info")
      end
    end
  end
end
