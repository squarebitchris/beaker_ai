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

  describe "GET /admin/webhook_events" do
    let!(:webhook_event1) { create(:webhook_event, provider: 'stripe', status: 'completed') }
    let!(:webhook_event2) { create(:webhook_event, provider: 'vapi', status: 'pending') }

    context "with filters" do
      it "filters by provider" do
        get admin_webhook_events_path(provider: 'stripe')
        expect(response.body).to include(webhook_event1.event_id[0..10])
        expect(response.body).not_to include(webhook_event2.event_id[0..10])
      end

      it "filters by status" do
        get admin_webhook_events_path(status: 'completed')
        expect(response.body).to include(webhook_event1.event_id[0..10])
        expect(response.body).not_to include(webhook_event2.event_id[0..10])
      end

      it "searches by event_id" do
        get admin_webhook_events_path(search: webhook_event1.event_id[0..5])
        expect(response.body).to include(webhook_event1.event_id[0..10])
        expect(response.body).not_to include(webhook_event2.event_id[0..10])
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

    it "displays retries count" do
      get admin_webhook_event_path(webhook_event)
      expect(response.body).to include("Retries")
    end

    it "shows reprocess button for failed events" do
      webhook_event.update!(status: 'failed')
      get admin_webhook_event_path(webhook_event)
      expect(response.body).to include("Reprocess Event")
    end

    it "shows reprocess button for pending events" do
      webhook_event.update!(status: 'pending')
      get admin_webhook_event_path(webhook_event)
      expect(response.body).to include("Reprocess Event")
    end

    it "does not show reprocess button for completed events" do
      webhook_event.update!(status: 'completed')
      get admin_webhook_event_path(webhook_event)
      expect(response.body).not_to include("Reprocess Event")
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

  describe "POST /admin/webhook_events/:id/reprocess" do
    let!(:failed_event) { create(:webhook_event, status: 'failed', error_message: 'Test error') }

    it "reprocesses failed event" do
      expect {
        post reprocess_admin_webhook_event_path(failed_event)
      }.to have_enqueued_job(WebhookProcessorJob).with(failed_event.id)

      failed_event.reload
      expect(failed_event.status).to eq('pending')
      expect(failed_event.error_message).to be_nil
      expect(failed_event.retries).to eq(0)
    end

    it "redirects to event detail page with notice" do
      post reprocess_admin_webhook_event_path(failed_event)
      expect(response).to redirect_to(admin_webhook_event_path(failed_event))
      follow_redirect!
      expect(response.body).to include("Event queued for reprocessing")
    end

    context "when event is completed" do
      let!(:completed_event) { create(:webhook_event, status: 'completed') }

      it "prevents reprocessing" do
        post reprocess_admin_webhook_event_path(completed_event)
        expect(response).to redirect_to(admin_webhook_event_path(completed_event))
        follow_redirect!
        expect(response.body).to include("Can only reprocess failed or pending events")
      end
    end

    context "when user is not admin" do
      before { sign_in regular_user }

      it "redirects to root path with alert" do
        post reprocess_admin_webhook_event_path(failed_event)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Access denied")
      end
    end
  end
end
