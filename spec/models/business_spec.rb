require 'rails_helper'

RSpec.describe Business, type: :model do
  describe 'associations' do
    it { should have_many(:business_ownerships).dependent(:destroy) }
    it { should have_many(:owners).through(:business_ownerships) }
    it { should have_many(:calls).dependent(:destroy) }
    # it { should have_one(:phone_number).dependent(:destroy) }  # TODO: Create PhoneNumber model in Phase 4
  end

  describe 'validations' do
    subject { build(:business) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:stripe_customer_id) }
    it { should validate_presence_of(:plan) }
    it { should validate_uniqueness_of(:stripe_customer_id) }
    it { should validate_numericality_of(:calls_included).is_greater_than(0) }
  end

  describe 'enums' do
    it 'defines status enum' do
      expect(Business.statuses).to eq({
        'active' => 'active',
        'past_due' => 'past_due',
        'canceled' => 'canceled'
      })
    end

    it 'defines plan enum' do
      expect(Business.plans).to eq({
        'starter' => 'starter',
        'pro' => 'pro'
      })
    end
  end

  describe 'callbacks' do
    it 'sets calls_included for starter plan' do
      business = Business.new(plan: 'starter', name: 'Test', stripe_customer_id: 'cus_test')
      business.valid?  # Trigger validations and callbacks
      expect(business.calls_included).to eq(100)
    end

    it 'sets calls_included for pro plan' do
      business = Business.new(plan: 'pro', name: 'Test', stripe_customer_id: 'cus_test')
      business.valid?  # Trigger validations and callbacks
      expect(business.calls_included).to eq(300)  # Updated from 500 to protect margins
    end

    # Remove test for unknown plan since enum validation prevents it
  end

  describe '#calls_remaining' do
    it 'calculates remaining calls' do
      business = build(:business, calls_included: 100, calls_used_this_period: 30)
      expect(business.calls_remaining).to eq(70)
    end
  end

  describe '#over_limit?' do
    it 'returns true when at limit' do
      business = build(:business, calls_included: 100, calls_used_this_period: 100)
      expect(business).to be_over_limit
    end

    it 'returns true when over limit' do
      business = build(:business, calls_included: 100, calls_used_this_period: 101)
      expect(business).to be_over_limit
    end

    it 'returns false when under limit' do
      business = build(:business, calls_included: 100, calls_used_this_period: 99)
      expect(business).not_to be_over_limit
    end
  end

  describe '#stripe_price_id' do
    it 'returns price_id from StripePlan for starter' do
      plan = create(:stripe_plan, plan_name: 'starter', stripe_price_id: 'price_123')
      business = build(:business, plan: 'starter')
      expect(business.stripe_price_id).to eq('price_123')
    end

    it 'returns price_id from StripePlan for pro' do
      plan = create(:stripe_plan, plan_name: 'pro', stripe_price_id: 'price_456')
      business = build(:business, plan: 'pro')
      expect(business.stripe_price_id).to eq('price_456')
    end

    it 'returns nil when StripePlan not found' do
      business = build(:business, plan: 'starter')
      expect(business.stripe_price_id).to be_nil
    end
  end

  describe 'StripePlan integration' do
    context 'with StripePlan records' do
      let!(:starter_plan) { create(:stripe_plan, plan_name: 'starter', calls_included: 100) }
      let!(:pro_plan) { create(:stripe_plan, plan_name: 'pro', calls_included: 300) }

      it 'uses StripePlan calls_included for starter' do
        business = create(:business, plan: 'starter', calls_included: nil)
        expect(business.calls_included).to eq(100)
      end

      it 'uses StripePlan calls_included for pro' do
        business = create(:business, plan: 'pro', calls_included: nil)
        expect(business.calls_included).to eq(300)
      end
    end

    context 'without StripePlan records (fallback)' do
      it 'falls back to default for starter' do
        business = Business.new(plan: 'starter', name: 'Test', stripe_customer_id: 'cus_test')
        business.valid?
        expect(business.calls_included).to eq(100)
      end

      it 'falls back to default for pro' do
        business = Business.new(plan: 'pro', name: 'Test', stripe_customer_id: 'cus_test')
        business.valid?
        expect(business.calls_included).to eq(300)
      end
    end
  end
end
