# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Upgrades", type: :request do
  let(:user) { create(:user) }
  let(:trial) { create(:trial, :active, user: user) }

  describe "GET /upgrade/:trial_id" do
    context "when authenticated" do
      before { sign_in user }

      it "renders the coming soon page" do
        get new_upgrade_path(trial_id: trial.id)

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Upgrade Coming Soon")
        expect(response.body).to include("Your own dedicated phone number")
      end

      it "tracks upgrade intent in session" do
        get new_upgrade_path(trial_id: trial.id)

        expect(session[:upgrade_intent]).to be_present
        expect(session[:upgrade_intent][:trial_id]).to eq(trial.id)
        expect(session[:upgrade_intent][:timestamp]).to be_present
      end

      it "logs upgrade intent" do
        allow(Rails.logger).to receive(:info)

        get new_upgrade_path(trial_id: trial.id)

        expect(Rails.logger).to have_received(:info).with(/User #{user.id} clicked upgrade CTA for trial #{trial.id}/)
      end
    end

    context "when not authenticated" do
      it "redirects to sign in" do
        get new_upgrade_path(trial_id: trial.id)

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
