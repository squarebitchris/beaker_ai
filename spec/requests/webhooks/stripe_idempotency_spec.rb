# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Stripe Webhook Idempotency', type: :request do
  let(:user) { create(:user) }
  let(:trial) { create(:trial, :active, user: user) }
  let(:stripe_subscription_id) { "sub_#{SecureRandom.hex(12)}" }

  let(:checkout_payload) do
    {
      id: 'evt_checkout_123',
      type: 'checkout.session.completed',
      data: {
        object: {
          id: 'cs_session_123',
          customer: 'cus_customer_123',
          subscription: stripe_subscription_id,
          metadata: {
            user_id: user.id,
            trial_id: trial.id,
            plan: 'starter',
            business_name: 'Test Business'
          }
        }
      }
    }.to_json
  end

  before do
    create(:scenario_template, key: 'hvac_lead_intake', active: true)
    allow(Stripe::Webhook).to receive(:construct_event).and_return(JSON.parse(checkout_payload))
    allow_any_instance_of(VapiClient).to receive(:create_assistant).and_return({ 'id' => 'asst_123' })
    allow(StripePlan).to receive(:for_plan).and_return(double(calls_included: 100))
  end

  it 'prevents duplicate business creation when webhook retries' do
    signature = 'valid_signature'

    # Process webhook twice (Stripe retry scenario)
    expect {
      2.times do
        post '/webhooks/stripe',
             params: checkout_payload,
             headers: {
               'Content-Type' => 'application/json',
               'Stripe-Signature' => signature
             }
      end

      # Process the jobs
      perform_enqueued_jobs
    }.to change(Business, :count).by(1)
     .and change(WebhookEvent, :count).by(1)  # Only one webhook event created

    # Verify business created correctly
    business = Business.find_by(stripe_subscription_id: stripe_subscription_id)
    expect(business).to be_present
    expect(business.name).to eq('Test Business')
  end

  it 'handles rapid webhook delivery (concurrent processing)' do
    # Simulate rapid webhook delivery before processing starts
    threads = Array.new(3) do
      Thread.new do
        post '/webhooks/stripe',
             params: checkout_payload,
             headers: {
               'Content-Type' => 'application/json',
               'Stripe-Signature' => 'valid_signature'
             }
      end
    end

    threads.each(&:join)

    # Process all enqueued jobs
    perform_enqueued_jobs

    # Only one business should exist despite multiple webhook deliveries
    expect(Business.where(stripe_subscription_id: stripe_subscription_id).count).to eq(1)
  end
end
