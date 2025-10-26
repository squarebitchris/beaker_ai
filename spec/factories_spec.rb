require 'rails_helper'

RSpec.describe 'Factories' do
  it 'lints successfully' do
    FactoryBot.lint traits: true, verbose: true
  end

  describe 'User factory' do
    it 'creates valid user' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'creates user with recent login trait' do
      user = build(:user, :with_recent_login)
      expect(user.current_sign_in_at).to be_present
    end
  end

  describe 'Trial factory' do
    it 'creates valid trial' do
      trial = build(:trial)
      expect(trial).to be_valid
    end

    it 'creates active trial' do
      trial = build(:trial, :active)
      expect(trial.status).to eq('active')
      expect(trial.vapi_assistant_id).to be_present
    end

    it 'creates expired trial' do
      trial = build(:trial, :expired)
      expect(trial.status).to eq('expired')
      expect(trial.expires_at).to be < Time.current
    end

    it 'creates trial with calls' do
      trial = create(:trial, :with_calls)
      expect(trial.calls.count).to eq(2)
    end
  end

  describe 'Call factory' do
    it 'creates valid call' do
      call = build(:call)
      expect(call).to be_valid
    end

    it 'creates completed call' do
      call = build(:call, :completed)
      expect(call.status).to eq('completed')
      expect(call.duration_seconds).to be_present
      expect(call.vapi_call_id).to be_present
    end

    it 'creates call with transcript' do
      call = build(:call, :with_transcript)
      expect(call.transcript).to be_present
      expect(call.extracted_lead).to be_present
    end
  end

  describe 'Business factory' do
    it 'creates valid business' do
      business = build(:business)
      expect(business).to be_valid
    end

    it 'creates pro plan business' do
      business = build(:business, :pro_plan)
      expect(business.plan).to eq('pro')
      expect(business.calls_included).to eq(500)
    end

    it 'creates business with owner' do
      business = create(:business, :with_owner)
      expect(business.owners.count).to eq(1)
    end
  end

  describe 'WebhookEvent factory' do
    it 'creates valid webhook event' do
      event = build(:webhook_event)
      expect(event).to be_valid
    end

    it 'creates pending event' do
      event = build(:webhook_event, :pending)
      expect(event.status).to eq('pending')
    end

    it 'creates completed event' do
      event = build(:webhook_event, :completed)
      expect(event.status).to eq('completed')
      expect(event.processed_at).to be_present
    end
  end

  describe 'BusinessOwnership factory' do
    it 'creates valid business ownership' do
      ownership = build(:business_ownership)
      expect(ownership).to be_valid
    end
  end
end
