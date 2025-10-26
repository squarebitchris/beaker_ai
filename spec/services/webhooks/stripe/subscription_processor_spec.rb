# frozen_string_literal: true

require "rails_helper"

RSpec.describe Webhooks::Stripe::SubscriptionProcessor do
  let(:webhook_event) do
    create(:webhook_event,
      provider: "stripe",
      event_id: "evt_subscription_123",
      event_type: "customer.subscription.updated",
      payload: {
        "type" => "customer.subscription.updated",
        "data" => {
          "object" => {
            "id" => "sub_123",
            "status" => "active"
          }
        }
      })
  end

  let(:processor) { described_class.new(webhook_event) }

  describe "#process" do
    it "does not raise an error" do
      expect { processor.process }.not_to raise_error
    end

    context "with different subscription event types" do
      context "with customer.subscription.created" do
        let(:webhook_event) do
          create(:webhook_event,
            provider: "stripe",
            event_id: "evt_sub_new",
            event_type: "customer.subscription.created",
            payload: {
              "type" => "customer.subscription.created",
              "data" => {
                "object" => {
                  "id" => "sub_new"
                }
              }
            })
        end

        it "processes without errors" do
          expect { processor.process }.not_to raise_error
        end
      end

      context "with customer.subscription.deleted" do
        let(:webhook_event) do
          create(:webhook_event,
            provider: "stripe",
            event_id: "evt_sub_deleted",
            event_type: "customer.subscription.deleted",
            payload: {
              "type" => "customer.subscription.deleted",
              "data" => {
                "object" => {
                  "id" => "sub_deleted"
                }
              }
            })
        end

        it "processes without errors" do
          expect { processor.process }.not_to raise_error
        end
      end
    end
  end
end
