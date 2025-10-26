require 'rails_helper'

RSpec.describe Call, type: :model do
  describe 'polymorphic associations' do
    it 'belongs to trial as callable' do
      trial = create(:trial)
      call = create(:call, callable: trial)
      expect(call.callable).to eq(trial)
      expect(trial.calls).to include(call)
    end

    it 'belongs to business as callable' do
      business = create(:business)
      call = create(:call, callable: business)
      expect(call.callable).to eq(business)
      expect(business.calls).to include(call)
    end
  end

  describe 'validations' do
    subject { build(:call) }

    it { should validate_presence_of(:to_e164) }
    it { should validate_uniqueness_of(:vapi_call_id).allow_nil }
    it { should validate_uniqueness_of(:twilio_call_sid).allow_nil }
  end

  describe 'enums' do
    it 'defines direction enum' do
      expect(Call.directions).to eq({
        'inbound' => 'inbound',
        'outbound_trial' => 'outbound_trial',
        'outbound_lead' => 'outbound_lead'
      })
    end

    it 'defines status enum' do
      expect(Call.statuses).to eq({
        'initiated' => 'initiated',
        'ringing' => 'ringing',
        'in_progress' => 'in_progress',
        'completed' => 'completed',
        'failed' => 'failed'
      })
    end
  end

  describe '#total_cost' do
    it 'sums all cost fields' do
      call = build(:call, vapi_cost: 0.50, twilio_cost: 0.05, openai_cost: 0.02)
      expect(call.total_cost).to eq(0.57)
    end

    it 'handles nil costs' do
      call = build(:call, vapi_cost: nil, twilio_cost: 0.05)
      expect(call.total_cost).to eq(0.05)
    end
  end

  describe '#duration_minutes' do
    it 'converts seconds to minutes' do
      call = build(:call, duration_seconds: 120)
      expect(call.duration_minutes).to eq(2.0)
    end

    it 'returns nil when duration_seconds is nil' do
      call = build(:call, duration_seconds: nil)
      expect(call.duration_minutes).to be_nil
    end
  end

  describe 'scopes' do
    let!(:completed_call) { create(:call, :completed) }
    let!(:initiated_call) { create(:call, status: 'initiated') }
    let!(:today_call) { create(:call, created_at: Time.current) }
    let!(:yesterday_call) { create(:call, created_at: 1.day.ago) }
    let!(:business_call) { create(:call, :for_business) }

    it '.completed returns only completed calls' do
      expect(Call.completed).to include(completed_call)
      expect(Call.completed).not_to include(initiated_call)
    end

    it '.today returns calls from today' do
      expect(Call.today).to include(today_call)
      expect(Call.today).not_to include(yesterday_call)
    end

    it '.for_business returns calls for specific business' do
      business = business_call.callable
      expect(Call.for_business(business.id)).to include(business_call)
      expect(Call.for_business(business.id)).not_to include(completed_call)
    end
  end

  describe 'Phase 2 scopes' do
    describe '.with_captured_leads' do
      it 'returns calls with captured data' do
        call_with_data = create(:call, :with_captured_lead)
        call_without_data = create(:call, captured: {})

        expect(Call.with_captured_leads).to include(call_with_data)
        expect(Call.with_captured_leads).not_to include(call_without_data)
      end
    end

    describe '.by_scenario' do
      it 'filters calls by scenario_slug' do
        lead_call = create(:call, :lead_intake_scenario)
        schedule_call = create(:call, :scheduling_scenario)

        expect(Call.by_scenario('lead_intake')).to include(lead_call)
        expect(Call.by_scenario('lead_intake')).not_to include(schedule_call)
      end
    end

    describe '.for_trial' do
      it 'returns only calls for specified trial' do
        trial1 = create(:trial)
        trial2 = create(:trial)
        call1 = create(:call, callable: trial1)
        call2 = create(:call, callable: trial2)

        expect(Call.for_trial(trial1.id)).to include(call1)
        expect(Call.for_trial(trial1.id)).not_to include(call2)
      end
    end
  end

  describe 'captured data helpers' do
    let(:call) { build(:call, :with_captured_lead) }

    describe '#captured_name' do
      it 'returns captured name' do
        expect(call.captured_name).to be_present
      end
    end

    describe '#captured_phone' do
      it 'returns captured phone' do
        expect(call.captured_phone).to match(/^\+1\d{10}$/)
      end
    end

    describe '#captured_email' do
      it 'returns captured email' do
        expect(call.captured_email).to include('@')
      end
    end

    describe '#captured_goal' do
      it 'returns captured goal' do
        expect(call.captured_goal).to eq('Request quote')
      end
    end

    describe '#has_captured_data?' do
      it 'returns true when captured has data' do
        expect(call.has_captured_data?).to be true
      end

      it 'returns false when captured is empty' do
        call.captured = {}
        expect(call.has_captured_data?).to be false
      end
    end
  end
end
