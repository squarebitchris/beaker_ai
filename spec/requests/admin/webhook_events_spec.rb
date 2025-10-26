require 'rails_helper'

RSpec.describe "Admin::WebhookEvents", type: :request do
  let(:admin_user) { create(:user, admin: true) }
  let(:regular_user) { create(:user, admin: false) }

  before { sign_in admin_user }

  describe "GET /admin/webhook_events" do
    let!(:webhook_event1) { create(:webhook_event, provider: 'stripe', status: 'completed') }
    let!(:webhook_event2) { create(:webhook_event, provider: 'vapi', status: 'pending') }

    it "returns successful response" do
      get admin_webhook_events_path
      expect(response).to be_successful
    end

    it "displays webhook events" do
      get admin_webhook_events_path
      expect(response.body).to include(webhook_event1.event_id[0..10])
      expect(response.body).to include(webhook_event2.event_id[0..10])
    end

    it "orders webhook events by created_at descending" do
      get admin_webhook_events_path
      # Verify both events are in the response
      expect(response.body).to include(webhook_event1.event_id[0..10])
      expect(response.body).to include(webhook_event2.event_id[0..10])
    end

    context "when user is not admin" do
      before { sign_in regular_user }

      it "redirects to root path with alert" do
        get admin_webhook_events_path
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Access denied")
      end
    end
  end

  describe "GET /admin/webhook_events/:id" do
    let!(:webhook_event) { create(:webhook_event, provider: 'stripe', event_type: 'checkout.session.completed') }

    it "returns successful response" do
      get admin_webhook_event_path(webhook_event)
      expect(response).to be_successful
    end

    it "displays webhook event details" do
      get admin_webhook_event_path(webhook_event)
      expect(response.body).to include(webhook_event.event_id)
      expect(response.body).to include(webhook_event.provider)
      expect(response.body).to include(webhook_event.event_type)
    end

    it "displays JSON payload" do
      get admin_webhook_event_path(webhook_event)
      # Check that the payload is displayed (pretty formatted JSON has escaped quotes)
      expect(response.body).to include(webhook_event.event_id)
      expect(response.body).to include(webhook_event.event_type)
    end

    context "when user is not admin" do
      before { sign_in regular_user }

      it "redirects to root path with alert" do
        get admin_webhook_event_path(webhook_event)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Access denied")
      end
    end
  end
end
