# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'

RSpec.describe "Upgrades", type: :request do
  let(:user) { create(:user) }
  let(:trial) { create(:trial, :active, user: user) }
  let!(:starter_plan) { create(:stripe_plan, :starter) }
  let!(:pro_plan) { create(:stripe_plan, :pro) }

  describe "GET /upgrade/:trial_id" do
    context "when authenticated" do
      before { sign_in user }

      it "renders plan selection page" do
        get new_upgrade_path(trial_id: trial.id)

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Choose Your Plan")
        expect(response.body).to include("starter")
        expect(response.body).to include("pro")
      end

      it "shows both plans with pricing" do
        get new_upgrade_path(trial_id: trial.id)

        expect(response.body).to include("$199")
        expect(response.body).to include("$499")
      end
    end

    context "when trial not owned by user" do
      let(:other_user) { create(:user) }
      let(:other_trial) { create(:trial, :active, user: other_user) }

      before { sign_in user }

      it "redirects with error" do
        get new_upgrade_path(trial_id: other_trial.id)

        expect(response).to redirect_to(new_trial_path)
        expect(flash[:alert]).to include("permission")
      end
    end

    context "when trial expired" do
      let(:expired_trial) { create(:trial, :expired, user: user) }

      before { sign_in user }

      it "redirects with error" do
        get new_upgrade_path(trial_id: expired_trial.id)

        expect(response).to redirect_to(new_trial_path)
        expect(flash[:alert]).to include("expired")
      end
    end

    context "when trial not ready" do
      let(:pending_trial) { create(:trial, user: user, status: "pending") }

      before { sign_in user }

      it "redirects with error" do
        get new_upgrade_path(trial_id: pending_trial.id)

        expect(response).to redirect_to(trial_path(pending_trial))
        expect(flash[:alert]).to include("ready")
      end
    end

    context "when trial already converted" do
      let(:converted_trial) { create(:trial, user: user, status: "converted") }

      before { sign_in user }

      it "redirects with error" do
        get new_upgrade_path(trial_id: converted_trial.id)

        expect(response).to redirect_to(trial_path(converted_trial))
        expect(flash[:alert]).to include("already been converted")
      end
    end

    context "when not authenticated" do
      it "redirects to sign in" do
        get new_upgrade_path(trial_id: trial.id)

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /upgrades/:trial_id" do
    before { sign_in user }

    context "with valid plan", vcr: false do
      before do
        WebMock.disable_net_connect!(allow_localhost: true)
        stub_request(:post, "https://api.stripe.com/v1/checkout/sessions")
          .to_return(
            status: 200,
            body: { id: "cs_test_123", url: "https://checkout.stripe.com/test/123" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "creates checkout session and redirects to Stripe" do
        post upgrades_path(trial_id: trial.id), params: { plan: "starter" }

        expect(response).to have_http_status(:redirect)
        expect(response.location).to start_with("https://checkout.stripe.com/")
      end

      it "tracks upgrade intent in session" do
        post upgrades_path(trial_id: trial.id), params: { plan: "pro" }

        expect(session[:upgrade_intent]).to be_present
        expect(session[:upgrade_intent][:trial_id]).to eq(trial.id)
        expect(session[:upgrade_intent][:plan]).to eq("pro")
      end
    end

    context "with invalid plan" do
      it "redirects with error" do
        post upgrades_path(trial_id: trial.id), params: { plan: "invalid" }

        expect(response).to redirect_to(new_upgrade_path(trial_id: trial.id))
        expect(flash[:error]).to include("Invalid plan")
      end
    end
  end
end
