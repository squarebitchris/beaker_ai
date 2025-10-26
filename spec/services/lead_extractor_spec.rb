# frozen_string_literal: true

require "rails_helper"

RSpec.describe LeadExtractor do
  describe ".from_function_calls" do
    context "with valid capture_lead function call" do
      let(:function_calls) do
        [
          {
            "name" => "capture_lead",
            "parameters" => {
              "name" => "John Smith",
              "phone" => "555-123-4567",
              "email" => "john@example.com",
              "intent" => "quote_request",
              "notes" => "Needs quote for new AC unit"
            }
          }
        ]
      end

      it "extracts all fields correctly" do
        result = described_class.from_function_calls(function_calls)

        expect(result).to eq(
          name: "John Smith",
          phone: "555-123-4567",
          email: "john@example.com",
          intent: "quote_request",
          notes: "Needs quote for new AC unit"
        )
      end
    end

    context "with partial data" do
      it "handles name only" do
        function_calls = [
          {
            "name" => "capture_lead",
            "parameters" => {
              "name" => "Jane Doe",
              "phone" => nil,
              "email" => nil
            }
          }
        ]

        result = described_class.from_function_calls(function_calls)

        expect(result).to eq(name: "Jane Doe")
        expect(result[:phone]).to be_nil
        expect(result[:email]).to be_nil
      end

      it "handles phone only" do
        function_calls = [
          {
            "name" => "capture_lead",
            "parameters" => {
              "name" => "",
              "phone" => "555-123-4567",
              "email" => ""
            }
          }
        ]

        result = described_class.from_function_calls(function_calls)

        expect(result).to eq(phone: "555-123-4567")
      end

      it "handles email and intent only" do
        function_calls = [
          {
            "name" => "capture_lead",
            "parameters" => {
              "name" => nil,
              "phone" => nil,
              "email" => "test@example.com",
              "intent" => "info"
            }
          }
        ]

        result = described_class.from_function_calls(function_calls)

        expect(result).to eq(
          email: "test@example.com",
          intent: "info"
        )
      end
    end

    context "with symbol keys instead of string keys" do
      it "handles indifferent access" do
        function_calls = [
          {
            name: "capture_lead",
            parameters: {
              name: "Bob Smith",
              phone: "555-987-6543",
              email: "bob@example.com"
            }
          }
        ]

        result = described_class.from_function_calls(function_calls)

        expect(result).to eq(
          name: "Bob Smith",
          phone: "555-987-6543",
          email: "bob@example.com"
        )
      end
    end

    context "with multiple function calls" do
      it "only extracts capture_lead function" do
        function_calls = [
          {
            "name" => "other_function",
            "parameters" => { "value" => "ignored" }
          },
          {
            "name" => "capture_lead",
            "parameters" => {
              "name" => "Alice",
              "phone" => "555-111-2222"
            }
          },
          {
            "name" => "yet_another",
            "parameters" => { "data" => "also ignored" }
          }
        ]

        result = described_class.from_function_calls(function_calls)

        expect(result).to eq(
          name: "Alice",
          phone: "555-111-2222"
        )
      end
    end

    context "with missing or invalid data" do
      it "returns empty hash when function_calls is nil" do
        expect(described_class.from_function_calls(nil)).to eq({})
      end

      it "returns empty hash when function_calls is empty array" do
        expect(described_class.from_function_calls([])).to eq({})
      end

      it "returns empty hash when no capture_lead function found" do
        function_calls = [
          { "name" => "other_function", "parameters" => {} }
        ]

        expect(described_class.from_function_calls(function_calls)).to eq({})
      end

      it "returns empty hash when function_calls is empty hash" do
        expect(described_class.from_function_calls({})).to eq({})
      end

      it "handles missing parameters key" do
        function_calls = [
          { "name" => "capture_lead" }
        ]

        expect(described_class.from_function_calls(function_calls)).to eq({})
      end

      it "handles empty parameters" do
        function_calls = [
          {
            "name" => "capture_lead",
            "parameters" => {}
          }
        ]

        expect(described_class.from_function_calls(function_calls)).to eq({})
      end
    end

    context "with single function call (not array)" do
      it "handles single hash instead of array" do
        single_call = {
          "name" => "capture_lead",
          "parameters" => {
            "name" => "Single Call Test",
            "phone" => "555-000-0000"
          }
        }

        result = described_class.from_function_calls(single_call)

        expect(result).to eq(
          name: "Single Call Test",
          phone: "555-000-0000"
        )
      end
    end

    context "with notes field containing long text" do
      it "preserves notes as-is" do
        long_notes = "This is a very long note about the customer's needs. They mentioned they have an old unit from 1998 and it's making weird noises. Also, their neighbor recommended us."
        function_calls = [
          {
            "name" => "capture_lead",
            "parameters" => {
              "name" => "Customer",
              "phone" => "555-111-2222",
              "notes" => long_notes
            }
          }
        ]

        result = described_class.from_function_calls(function_calls)

        expect(result[:notes]).to eq(long_notes)
      end
    end
  end
end
