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
end
