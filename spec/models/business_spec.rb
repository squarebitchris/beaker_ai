require 'rails_helper'

RSpec.describe Business, type: :model do
  describe 'associations' do
    it { should have_many(:business_ownerships).dependent(:destroy) }
    it { should have_many(:owners).through(:business_ownerships) }
    it { should have_many(:calls).dependent(:destroy) }
    it { should have_one(:phone_number).dependent(:destroy) }
  end

  describe '#has_phone_number?' do
    it 'responds to has_phone_number?' do
      business = build(:business)
      expect(business).to respond_to(:has_phone_number?)
    end

    it 'returns false when no phone number' do
      business = build(:business)
      expect(business.has_phone_number?).to be false
    end

    it 'returns true when phone number exists' do
      business = create(:business)
      create(:phone_number, business: business)
      expect(business.has_phone_number?).to be true
    end
  end

  describe 'validations' do
    subject { build(:business) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:stripe_customer_id) }
    it { should validate_presence_of(:plan) }
    it { should validate_uniqueness_of(:stripe_customer_id) }
    it { should validate_uniqueness_of(:stripe_subscription_id).allow_nil }
    it { should validate_numericality_of(:calls_included).is_greater_than(0) }
  end

  describe 'database constraints' do
    it 'enforces unique stripe_subscription_id (Rails validation first)' do
      # Create first business with subscription_id
      create(:business, stripe_subscription_id: 'sub_unique123')

      # Attempt to create duplicate - Rails validation catches it first
      expect {
        Business.create!(
          name: 'Duplicate Business',
          stripe_customer_id: 'cus_different',
          stripe_subscription_id: 'sub_unique123',  # Same subscription ID
          plan: 'starter',
          calls_included: 100
        )
      }.to raise_error(ActiveRecord::RecordInvalid, /Stripe subscription has already been taken/)
    end

    it 'allows multiple businesses with NULL subscription_id' do
      business1 = create(:business, stripe_subscription_id: nil)
      business2 = create(:business, stripe_subscription_id: nil)

      expect(business1).to be_persisted
      expect(business2).to be_persisted
    end
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
