require 'rails_helper'

RSpec.describe WebhookEvent, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:event_id) }
    it { should validate_presence_of(:event_type) }

    it 'validates uniqueness of event_id scoped to provider' do
      create(:webhook_event, provider: 'stripe', event_id: 'evt_123')
      duplicate_event = build(:webhook_event, provider: 'stripe', event_id: 'evt_123')

      expect(duplicate_event).not_to be_valid
      expect(duplicate_event.errors[:event_id]).to include('has already been taken')
    end
  end

  describe 'enums' do
    it 'has status enum' do
      expect(WebhookEvent.statuses).to eq({
        'pending' => 'pending',
        'processing' => 'processing',
        'completed' => 'completed',
        'failed' => 'failed'
      })
    end

    it 'has provider enum' do
      expect(WebhookEvent.providers).to eq({
        'stripe' => 'stripe',
        'twilio' => 'twilio',
        'vapi' => 'vapi'
      })
    end
  end

  describe 'scopes' do
    let!(:pending_event) { create(:webhook_event, status: 'pending', retries: 0) }
    let!(:failed_event) { create(:webhook_event, status: 'failed', retries: 2) }
    let!(:completed_event) { create(:webhook_event, status: 'completed') }
    let!(:max_retries_event) { create(:webhook_event, status: 'failed', retries: 3) }
    let!(:old_event) { create(:webhook_event, created_at: 8.days.ago) }
    let!(:recent_event) { create(:webhook_event, created_at: 3.days.ago) }

    describe '.unprocessed' do
      it 'returns pending and failed events with retries < 3' do
        expect(WebhookEvent.unprocessed).to include(pending_event, failed_event)
        expect(WebhookEvent.unprocessed).not_to include(completed_event, max_retries_event)
      end
    end

    describe '.recent' do
      it 'returns events created within 7 days' do
        expect(WebhookEvent.recent).to include(recent_event)
        expect(WebhookEvent.recent).not_to include(old_event)
      end
    end
  end

  describe '#mark_processing!' do
    it 'updates status to processing and sets processed_at' do
      event = create(:webhook_event, status: 'pending')

      event.mark_processing!

      expect(event.status).to eq('processing')
      expect(event.processed_at).to be_present
    end
  end

  describe '#mark_completed!' do
    it 'updates status to completed' do
      event = create(:webhook_event, status: 'processing')

      event.mark_completed!

      expect(event.status).to eq('completed')
    end
  end

  describe '#mark_failed!' do
    it 'updates status to failed, increments retries, and sets error message' do
      event = create(:webhook_event, status: 'processing', retries: 1)
      error = StandardError.new('Test error')

      event.mark_failed!(error)

      expect(event.status).to eq('failed')
      expect(event.retries).to eq(2)
      expect(event.error_message).to eq('Test error')
    end
  end
end
