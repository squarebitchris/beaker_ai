# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Onboarding", type: :request do
  let(:user) { create(:user) }

  describe "GET /onboarding" do
    before { sign_in user }

    it "shows onboarding page with valid session_id" do
      get onboarding_path(session_id: "cs_test_123")

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Setting Up Your Account")
    end

    it "redirects with invalid session_id" do
      get onboarding_path(session_id: "invalid")

      expect(response).to redirect_to(new_trial_path)
      expect(flash[:error]).to include("Invalid session ID")
    end
  end

  describe "GET /onboarding/status" do
    let(:checkout_session_id) { "cs_test_123" }
    let(:subscription_id) { "sub_test_456" }

    context "when business is ready" do
      let!(:business) { create(:business, stripe_subscription_id: subscription_id, plan: "starter") }

      before do
        allow_any_instance_of(StripeClient).to receive(:get_checkout_session).and_return(
          double(subscription: subscription_id)
        )
      end

      it "returns ready status with redirect URL" do
        get onboarding_status_path(session_id: checkout_session_id)

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json["status"]).to eq("ready")
        expect(json["redirect_url"]).to be_present
        expect(json["business_id"]).to eq(business.id)
      end
    end

    context "when business is pending" do
      before do
        allow_any_instance_of(StripeClient).to receive(:get_checkout_session).and_return(
          double(subscription: subscription_id)
        )
        # Business not created yet (job still processing)
      end

      it "returns pending status" do
        get onboarding_status_path(session_id: checkout_session_id)

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json["status"]).to eq("pending")
        expect(json["message"]).to eq("Setting up your account...")
      end
    end

    context "when checkout session not found" do
      before do
        allow_any_instance_of(StripeClient).to receive(:get_checkout_session).and_return(nil)
      end

      it "returns failed status" do
        get onboarding_status_path(session_id: checkout_session_id)

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json["status"]).to eq("failed")
        expect(json["message"]).to include("not found")
      end
    end

    context "when subscription not yet created" do
      before do
        allow_any_instance_of(StripeClient).to receive(:get_checkout_session).and_return(
          double(subscription: nil)
        )
      end

      it "returns pending status waiting for subscription" do
        get onboarding_status_path(session_id: checkout_session_id)

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json["status"]).to eq("pending")
        expect(json["message"]).to eq("Waiting for subscription to be created...")
      end
    end

    context "when StripeClient raises error" do
      before do
        allow_any_instance_of(StripeClient).to receive(:get_checkout_session).and_raise(StandardError, "API error")
      end

      it "returns failed status" do
        get onboarding_status_path(session_id: checkout_session_id)

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json["status"]).to eq("failed")
      end
    end
  end

  describe "GET /success" do
    before { sign_in user }

    it "shows success page" do
      get checkout_success_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Thank You")
    end
  end

  describe "GET /cancel" do
    it "shows cancel page without auth" do
      get checkout_cancel_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Checkout Cancelled")
    end
  end
end
