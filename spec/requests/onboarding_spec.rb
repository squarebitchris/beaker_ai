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
    # No auth needed for status endpoint

    it "returns pending status (Phase 3 placeholder)" do
      get onboarding_status_path(session_id: "cs_test_123")

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json["status"]).to eq("pending")
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

