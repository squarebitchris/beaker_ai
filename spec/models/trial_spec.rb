require 'rails_helper'

RSpec.describe Trial, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:scenario_template).optional }
    it { should have_many(:calls).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:business_name) }
    it { should validate_presence_of(:scenario) }
    it { should validate_presence_of(:phone_e164) }

    it 'validates calls_used is non-negative' do
      trial = build(:trial, calls_used: -1)
      expect(trial).not_to be_valid
      expect(trial.errors[:calls_used]).to include('must be greater than or equal to 0')
    end

    it 'enforces calls_used <= calls_limit' do
      trial = build(:trial, calls_used: 4, calls_limit: 3)
      expect(trial).not_to be_valid
      expect(trial.errors[:calls_used]).to include(/cannot exceed limit/)
    end
  end

  describe 'enums' do
    it 'defines status enum' do
      expect(Trial.statuses).to eq({
        'pending' => 'pending',
        'active' => 'active',
        'converted' => 'converted',
        'expired' => 'expired'
      })
    end

    it 'defines industry enum' do
      expect(Trial.industries).to eq({
        'hvac' => 'hvac',
        'gym' => 'gym',
        'dental' => 'dental'
      })
    end
  end

  describe 'callbacks' do
    it 'sets expires_at on creation' do
      trial = create(:trial)
      expect(trial.expires_at).to be_within(1.second).of(48.hours.from_now)
    end
  end

  describe '#calls_remaining' do
    it 'calculates remaining calls' do
      trial = build(:trial, calls_used: 1, calls_limit: 3)
      expect(trial.calls_remaining).to eq(2)
    end
  end

  describe '#expired?' do
    it 'returns true if past expiration' do
      trial = build(:trial, expires_at: 1.hour.ago)
      expect(trial).to be_expired
    end

    it 'returns false if not expired' do
      trial = build(:trial, expires_at: 1.hour.from_now)
      expect(trial).not_to be_expired
    end
  end

  describe 'scopes' do
    let!(:active_trial) { create(:trial, status: 'active', expires_at: 1.hour.from_now) }
    let!(:expired_trial) { create(:trial, status: 'active', expires_at: 1.hour.ago) }
    let!(:pending_trial) { create(:trial, status: 'pending', expires_at: 1.hour.ago) }
    let!(:ready_trial) { create(:trial, vapi_assistant_id: 'asst_123') }
    let!(:not_ready_trial) { create(:trial, vapi_assistant_id: nil) }

    it '.active returns only non-expired active trials' do
      expect(Trial.active).to include(active_trial)
      expect(Trial.active).not_to include(expired_trial)
      expect(Trial.active).not_to include(pending_trial)
    end

    it '.expired_pending returns only expired pending trials' do
      expect(Trial.expired_pending).to include(pending_trial)
      expect(Trial.expired_pending).not_to include(active_trial)
      expect(Trial.expired_pending).not_to include(expired_trial)
    end

    it '.ready returns only trials with vapi_assistant_id' do
      expect(Trial.ready).to include(ready_trial)
      expect(Trial.ready).not_to include(not_ready_trial)
    end
  end

  describe 'scenario_template association' do
    it 'can exist without a scenario template' do
      trial = create(:trial, scenario_template: nil)
      expect(trial.scenario_template).to be_nil
    end

    it 'can be associated with a scenario template' do
      template = create(:scenario_template)
      trial = create(:trial, scenario_template: template)
      expect(trial.scenario_template).to eq(template)
    end
  end
end
