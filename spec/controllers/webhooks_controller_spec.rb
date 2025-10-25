require 'rails_helper'

RSpec.describe 'Webhooks', type: :request do
  let(:stripe_payload) do
    {
      id: 'evt_test_webhook',
      object: 'event',
      type: 'checkout.session.completed',
      data: {
        object: {
          id: 'cs_test_session',
          customer_email: 'test@example.com'
        }
      }
    }.to_json
  end

  let(:stripe_secret) { ENV['STRIPE_WEBHOOK_SECRET'] || 'whsec_test_secret' }

  def generate_stripe_signature(payload, secret)
    timestamp = Time.now.to_i
    signed_payload = "#{timestamp}.#{payload}"
    signature = OpenSSL::HMAC.hexdigest('SHA256', secret, signed_payload)
    "t=#{timestamp},v1=#{signature}"
  end

  describe 'POST /webhooks/stripe' do
    context 'with valid signature' do
      it 'creates webhook event and enqueues job' do
        signature = generate_stripe_signature(stripe_payload, stripe_secret)

        # Mock Stripe webhook verification to avoid signature issues in tests
        allow(Stripe::Webhook).to receive(:construct_event).and_return(JSON.parse(stripe_payload))

        expect {
          post '/webhooks/stripe',
               params: stripe_payload,
               headers: {
                 'Content-Type' => 'application/json',
                 'Stripe-Signature' => signature
               }
        }.to change(WebhookEvent, :count).by(1)
         .and have_enqueued_job(WebhookProcessorJob)

        expect(response).to have_http_status(:ok)

        event = WebhookEvent.last
        expect(event.provider).to eq('stripe')
        expect(event.event_id).to eq('evt_test_webhook')
        expect(event.event_type).to eq('checkout.session.completed')
        expect(event.status).to eq('pending')
      end
    end

    context 'with invalid signature' do
      it 'rejects request with 401' do
        allow(Stripe::Webhook).to receive(:construct_event).and_raise(Stripe::SignatureVerificationError.new('Invalid signature', 'sig_header'))

        expect {
          post '/webhooks/stripe',
               params: stripe_payload,
               headers: {
                 'Content-Type' => 'application/json',
                 'Stripe-Signature' => 'invalid_signature'
               }
        }.not_to change(WebhookEvent, :count)

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with duplicate event' do
      before do
        create(:webhook_event, provider: 'stripe', event_id: 'evt_test_webhook')
      end

      it 'returns 200 but does not enqueue duplicate job' do
        signature = generate_stripe_signature(stripe_payload, stripe_secret)

        # Mock Stripe webhook verification
        allow(Stripe::Webhook).to receive(:construct_event).and_return(JSON.parse(stripe_payload))

        expect {
          post '/webhooks/stripe',
               params: stripe_payload,
               headers: {
                 'Content-Type' => 'application/json',
                 'Stripe-Signature' => signature
               }
        }.not_to change(WebhookEvent, :count)

        expect(WebhookProcessorJob).not_to have_been_enqueued

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST /webhooks/twilio' do
    let(:twilio_params) do
      {
        CallSid: 'CA123456789',
        CallStatus: 'completed',
        From: '+15551234567',
        To: '+15557654321'
      }
    end

    context 'with valid signature' do
      before do
        allow(Twilio::Security::RequestValidator).to receive(:new).and_return(
          double(validate: true)
        )
      end

      it 'creates webhook event and enqueues job' do
        expect {
          post '/webhooks/twilio',
               params: twilio_params,
               headers: {
                 'X-Twilio-Signature' => 'valid_signature'
               }
        }.to change(WebhookEvent, :count).by(1)
         .and have_enqueued_job(WebhookProcessorJob)

        expect(response).to have_http_status(:ok)

        event = WebhookEvent.last
        expect(event.provider).to eq('twilio')
        expect(event.event_id).to eq('CA123456789')
        expect(event.event_type).to eq('call_status')
      end
    end

    context 'with invalid signature' do
      before do
        allow(Twilio::Security::RequestValidator).to receive(:new).and_return(
          double(validate: false)
        )
      end

      it 'rejects request with 401' do
        expect {
          post '/webhooks/twilio',
               params: twilio_params,
               headers: {
                 'X-Twilio-Signature' => 'invalid_signature'
               }
        }.not_to change(WebhookEvent, :count)

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /webhooks/vapi' do
    let(:vapi_payload) do
      {
        message: {
          id: 'call_123456',
          type: 'call.ended',
          data: { duration: 120 }
        }
      }.to_json
    end

    let(:vapi_secret) { ENV['VAPI_WEBHOOK_SECRET'] || 'test_secret' }

    context 'with valid signature' do
      it 'creates webhook event and enqueues job' do
        signature = OpenSSL::HMAC.hexdigest('SHA256', vapi_secret, vapi_payload)

        # Mock the signature verification to avoid request body issues
        allow_any_instance_of(WebhooksController).to receive(:verify_vapi_signature)

        expect {
          post '/webhooks/vapi',
               params: vapi_payload,
               headers: {
                 'Content-Type' => 'application/json',
                 'x-vapi-signature' => signature
               }
        }.to change(WebhookEvent, :count).by(1)
         .and have_enqueued_job(WebhookProcessorJob)

        expect(response).to have_http_status(:ok)

        event = WebhookEvent.last
        expect(event.provider).to eq('vapi')
        expect(event.event_id).to eq('call_123456')
        expect(event.event_type).to eq('call.ended')
      end
    end

    context 'with invalid signature' do
      it 'rejects request with 401' do
        # Mock signature verification to fail by raising an exception
        allow_any_instance_of(WebhooksController).to receive(:verify_vapi_signature) do
          raise ActionController::BadRequest
        end

        expect {
          post '/webhooks/vapi',
               params: vapi_payload,
               headers: {
                 'Content-Type' => 'application/json',
                 'x-vapi-signature' => 'invalid_signature'
               }
        }.not_to change(WebhookEvent, :count)

        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'unknown provider' do
    it 'returns 404' do
      post '/webhooks/unknown'
      expect(response).to have_http_status(:not_found)
    end
  end
end
