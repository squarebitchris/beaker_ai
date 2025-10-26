require 'rails_helper'

RSpec.describe Admin::WebhookEventsHelper do
  include described_class

  describe "#mask_pii_in_json" do
    it "masks email addresses" do
      payload = { "customer_email" => "john@example.com" }
      result = mask_pii_in_json(payload)
      expect(result["customer_email"]).to eq("j***@e***")
    end

    it "masks phone numbers with e164" do
      payload = { "phone_e164" => "+15551234567" }
      result = mask_pii_in_json(payload)
      expect(result["phone_e164"]).to eq("***4567")
    end

    it "masks phone numbers with 'phone' in key" do
      payload = { "phone_number" => "+15551234567" }
      result = mask_pii_in_json(payload)
      expect(result["phone_number"]).to eq("***4567")
    end

    it "handles nested structures" do
      payload = {
        "customer" => {
          "email" => "jane@example.com",
          "phone" => "+15559876543"
        }
      }
      result = mask_pii_in_json(payload)
      expect(result["customer"]["email"]).to eq("j***@e***")
      expect(result["customer"]["phone"]).to eq("***6543")
    end

    it "handles arrays" do
      payload = {
        "contacts" => [
          { "email" => "alice@example.com" },
          { "email" => "bob@example.com" }
        ]
      }
      result = mask_pii_in_json(payload)
      expect(result["contacts"][0]["email"]).to eq("a***@e***")
      expect(result["contacts"][1]["email"]).to eq("b***@e***")
    end

    it "leaves non-sensitive data unchanged" do
      payload = { "order_id" => "12345", "amount" => "100" }
      result = mask_pii_in_json(payload)
      expect(result["order_id"]).to eq("12345")
      expect(result["amount"]).to eq("100")
    end

    it "returns non-hash payloads unchanged" do
      expect(mask_pii_in_json("string")).to eq("string")
      expect(mask_pii_in_json(123)).to eq(123)
      expect(mask_pii_in_json(nil)).to eq(nil)
    end

    it "handles complex nested structures" do
      payload = {
        "data" => {
          "object" => {
            "customer_email" => "test@example.com",
            "metadata" => {
              "phone_e164" => "+15551112222"
            }
          }
        }
      }
      result = mask_pii_in_json(payload)
      expect(result.dig("data", "object", "customer_email")).to eq("t***@e***")
      expect(result.dig("data", "object", "metadata", "phone_e164")).to eq("***2222")
    end
  end
end
