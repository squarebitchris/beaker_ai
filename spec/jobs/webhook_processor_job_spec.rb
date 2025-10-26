require 'rails_helper'

RSpec.describe WebhookProcessorJob, type: :job do
  let(:webhook_event) { create(:webhook_event, provider: 'stripe', event_type: 'checkout.session.completed') }

  describe '#perform' do
    context 'when processing succeeds' do
      it 'marks event as completed' do
        perform_enqueued_jobs do
          WebhookProcessorJob.perform_later(webhook_event.id)
        end

        webhook_event.reload
        expect(webhook_event.status).to eq('completed')
        expect(webhook_event.processed_at).to be_present
      end
    end

    context 'when event is already completed' do
      before { webhook_event.update!(status: 'completed') }

      it 'skips processing' do
        expect(webhook_event).not_to receive(:mark_processing!)

        perform_enqueued_jobs do
          WebhookProcessorJob.perform_later(webhook_event.id)
        end
      end
    end

    context 'with different event types' do
      it 'processes different provider events' do
        stripe_event = create(:webhook_event, :stripe)
        twilio_event = create(:webhook_event, :twilio)
        vapi_event = create(:webhook_event, :vapi)

        perform_enqueued_jobs do
          WebhookProcessorJob.perform_later(stripe_event.id)
          WebhookProcessorJob.perform_later(twilio_event.id)
          WebhookProcessorJob.perform_later(vapi_event.id)
        end

        [ stripe_event, twilio_event, vapi_event ].each do |event|
          event.reload
          expect(event.status).to eq('completed')
        end
      end
    end

    context 'with unknown event type' do
      let(:unknown_event) { create(:webhook_event, provider: 'stripe', event_type: 'unknown.event') }

      it 'completes event even for unknown types' do
        perform_enqueued_jobs do
          WebhookProcessorJob.perform_later(unknown_event.id)
        end

        unknown_event.reload
        expect(unknown_event.status).to eq('completed')
      end
    end
  end

  describe 'Vapi event processing integration' do
    let!(:trial) { create(:trial, :active, vapi_assistant_id: 'asst_123456') }
    let(:vapi_event) do
      create(:webhook_event,
        provider: "vapi",
        event_id: "call_abc123",
        event_type: "call.ended",
        payload: {
          "type" => "call.ended",
          "call" => {
            "id" => "call_abc123",
            "status" => "ended",
            "duration" => 120,
            "recordingUrl" => "https://storage.vapi.ai/recordings/call_abc123.mp3",
            "transcript" => "Agent: Hello, how can I help you?",
            "cost" => 0.15,
            "startedAt" => "2025-01-26T10:30:00Z",
            "endedAt" => "2025-01-26T10:32:00Z"
          },
          "assistant" => {
            "id" => "asst_123456"
          }
        })
    end

    context 'when Vapi call.ended event is processed' do
      it 'creates a Call record for the trial' do
        expect {
          perform_enqueued_jobs do
            WebhookProcessorJob.perform_later(vapi_event.id)
          end
        }.to change(Call, :count).by(1)

        # Verify the call was created correctly
        call = Call.find_by(vapi_call_id: "call_abc123")
        expect(call).to be_present
        expect(call.callable).to eq(trial)
        expect(call.intent).to be_present
        expect(call.intent).to eq("info")  # Based on payload without function calls
      end

      it 'increments trial calls_used' do
        initial_count = trial.calls_used

        perform_enqueued_jobs do
          WebhookProcessorJob.perform_later(vapi_event.id)
        end

        trial.reload
        expect(trial.calls_used).to eq(initial_count + 1)
      end

      it 'marks event as completed' do
        perform_enqueued_jobs do
          WebhookProcessorJob.perform_later(vapi_event.id)
        end

        vapi_event.reload
        expect(vapi_event.status).to eq('completed')
        expect(vapi_event.processed_at).to be_present
      end
    end

    context 'when Vapi event processing fails' do
      before do
        # Force the trial lookup to fail
        allow(Trial).to receive(:find_by).and_return(nil)
      end

      it 'marks event as completed even if no trial found' do
        expect(Sentry).not_to receive(:capture_exception)

        perform_enqueued_jobs do
          WebhookProcessorJob.perform_later(vapi_event.id)
        end

        vapi_event.reload
        expect(vapi_event.status).to eq('completed')
      end
    end

    context 'with duplicate Vapi event (idempotency)' do
      let!(:existing_call) do
        create(:call, vapi_call_id: 'call_abc123', callable: trial)
      end

      it 'does not create duplicate Call' do
        expect {
          perform_enqueued_jobs do
            WebhookProcessorJob.perform_later(vapi_event.id)
          end
        }.not_to change(Call, :count)
      end

      it 'marks event as completed' do
        perform_enqueued_jobs do
          WebhookProcessorJob.perform_later(vapi_event.id)
        end

        vapi_event.reload
        expect(vapi_event.status).to eq('completed')
      end
    end

    context 'with non-call.ended Vapi events' do
      let(:call_started_event) do
        create(:webhook_event,
          provider: "vapi",
          event_type: "call.started",
          payload: {
            "type" => "call.started",
            "call" => { "id" => "call_xyz789", "status" => "started" },
            "assistant" => { "id" => "asst_123456" }
          })
      end

      it 'ignores non-call.ended events' do
        expect {
          perform_enqueued_jobs do
            WebhookProcessorJob.perform_later(call_started_event.id)
          end
        }.not_to change(Call, :count)
      end

      it 'still marks event as completed' do
        perform_enqueued_jobs do
          WebhookProcessorJob.perform_later(call_started_event.id)
        end

        call_started_event.reload
        expect(call_started_event.status).to eq('completed')
      end
    end
  end

  describe 'Stripe event processing integration' do
    let(:user) { create(:user) }
    let(:trial) { create(:trial, user: user) }

    context 'when checkout.session.completed event is processed' do
      let(:stripe_event) do
        create(:webhook_event,
          provider: "stripe",
          event_id: "evt_checkout_123",
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

      it 'processes without errors' do
        perform_enqueued_jobs do
          WebhookProcessorJob.perform_later(stripe_event.id)
        end

        stripe_event.reload
        expect(stripe_event.status).to eq('completed')
      end
    end

    context 'when customer.subscription.* event is processed' do
      let(:subscription_event) do
        create(:webhook_event,
          provider: "stripe",
          event_id: "evt_sub_updated",
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

      it 'processes subscription event successfully' do
        perform_enqueued_jobs do
          WebhookProcessorJob.perform_later(subscription_event.id)
        end

        subscription_event.reload
        expect(subscription_event.status).to eq('completed')
      end
    end

    context 'with unknown Stripe event type' do
      let(:unknown_stripe_event) do
        create(:webhook_event,
          provider: "stripe",
          event_id: "evt_unknown",
          event_type: "payment_intent.succeeded",
          payload: {
            "type" => "payment_intent.succeeded",
            "data" => {}
          })
      end

      it 'processes unknown event successfully' do
        perform_enqueued_jobs do
          WebhookProcessorJob.perform_later(unknown_stripe_event.id)
        end

        unknown_stripe_event.reload
        expect(unknown_stripe_event.status).to eq('completed')
      end
    end

    context 'with missing metadata in checkout.session.completed' do
      let(:invalid_stripe_event) do
        create(:webhook_event,
          provider: "stripe",
          event_id: "evt_no_metadata",
          event_type: "checkout.session.completed",
          payload: {
            "type" => "checkout.session.completed",
            "data" => {
              "object" => {
                "id" => "cs_test_123",
                "customer" => "cus_123"
                # Missing metadata
              }
            }
          })
      end

      it 'processes event even with missing metadata' do
        perform_enqueued_jobs do
          WebhookProcessorJob.perform_later(invalid_stripe_event.id)
        end

        invalid_stripe_event.reload
        expect(invalid_stripe_event.status).to eq('completed')
      end
    end
  end
end
