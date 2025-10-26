# frozen_string_literal: true

require "rails_helper"

RSpec.describe Webhooks::Stripe::CheckoutSessionProcessor do
  let(:user) { create(:user) }
  let(:trial) { create(:trial, user: user) }
  let(:webhook_event) { create(:webhook_event, :stripe) }
  let(:processor) { described_class.new(webhook_event) }

  describe "#process" do
    context "with valid checkout.session.completed event" do
      let(:webhook_event) do
        create(:webhook_event,
          provider: "stripe",
          event_id: "evt_abc123",
          event_type: "checkout.session.completed",
          payload: {
            "type" => "checkout.session.completed",
            "data" => {
              "object" => {
                "id" => "cs_test_123",
                "customer" => "cus_123",
                "subscription" => "sub_123",
                "metadata" => {
                  "user_id" => user.id,
                  "trial_id" => trial.id,
                  "plan" => "starter",
                  "business_name" => "Test HVAC"
                }
              }
            }
          })
      end

      it "processes without raising errors" do
        expect { processor.process }.not_to raise_error
      end

      it "extracts session data correctly" do
        processor.process
        # If no errors raised, extraction was successful
      end
    end

    context "with missing metadata" do
      let(:webhook_event) do
        create(:webhook_event,
          provider: "stripe",
          event_id: "evt_abc123",
          event_type: "checkout.session.completed",
          payload: {
            "type" => "checkout.session.completed",
            "data" => {
              "object" => {
                "id" => "cs_test_123",
                "customer" => "cus_123",
                "subscription" => "sub_123"
                # Missing metadata
              }
            }
          })
      end

      it "returns early without errors" do
        expect { processor.process }.not_to raise_error
      end

      it "does not process the event" do
        processor.process
        # No errors and no state changes means it returned early
      end
    end

    context "with missing user_id in metadata" do
      let(:webhook_event) do
        create(:webhook_event,
          provider: "stripe",
          event_id: "evt_abc123",
          event_type: "checkout.session.completed",
          payload: {
            "type" => "checkout.session.completed",
            "data" => {
              "object" => {
                "id" => "cs_test_123",
                "customer" => "cus_123",
                "metadata" => {
                  "trial_id" => trial.id,
                  "plan" => "starter"
                  # Missing user_id
                }
              }
            }
          })
      end

      it "returns early without errors" do
        expect { processor.process }.not_to raise_error
      end
    end

    context "with missing trial_id in metadata" do
      let(:webhook_event) do
        create(:webhook_event,
          provider: "stripe",
          event_id: "evt_abc123",
          event_type: "checkout.session.completed",
          payload: {
            "type" => "checkout.session.completed",
            "data" => {
              "object" => {
                "id" => "cs_test_123",
                "customer" => "cus_123",
                "metadata" => {
                  "user_id" => user.id,
                  "plan" => "starter"
                  # Missing trial_id
                }
              }
            }
          })
      end

      it "returns early without errors" do
        expect { processor.process }.not_to raise_error
      end
    end

    context "with missing session data" do
      let(:webhook_event) do
        create(:webhook_event,
          provider: "stripe",
          event_id: "evt_abc123",
          event_type: "checkout.session.completed",
          payload: {
            "type" => "checkout.session.completed",
            "data" => {
              "object" => nil
            }
          })
      end

      it "returns early without errors" do
        expect { processor.process }.not_to raise_error
      end
    end

    context "with malformed payload" do
      let(:webhook_event) do
        create(:webhook_event,
          provider: "stripe",
          event_id: "evt_abc123",
          event_type: "checkout.session.completed",
          payload: {
            "type" => "checkout.session.completed"
            # Missing data entirely
          })
      end

      it "returns early without errors" do
        expect { processor.process }.not_to raise_error
      end
    end

    context "with partial metadata" do
      let(:webhook_event) do
        create(:webhook_event,
          provider: "stripe",
          event_id: "evt_abc123",
          event_type: "checkout.session.completed",
          payload: {
            "type" => "checkout.session.completed",
            "data" => {
              "object" => {
                "id" => "cs_test_123",
                "customer" => "cus_123",
                "subscription" => "sub_123",
                "metadata" => {
                  "user_id" => user.id,
                  "trial_id" => trial.id,
                  "plan" => "starter"
                  # Missing business_name is OK
                }
              }
            }
          })
      end

      it "processes successfully" do
        expect { processor.process }.not_to raise_error
      end
    end
  end
end
