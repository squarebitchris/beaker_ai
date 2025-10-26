require 'rails_helper'

RSpec.describe EmailSubscription, type: :model do
  describe 'associations' do
    it { should belong_to(:user).optional }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:source) }
    it { should validate_inclusion_of(:marketing_consent).in_array([ true, false ]) }
  end

  describe 'email uniqueness' do
    it 'enforces case-insensitive uniqueness via Rails validation' do
      create(:email_subscription, email: 'test@example.com')

      expect {
        create(:email_subscription, email: 'TEST@example.com')
      }.to raise_error(ActiveRecord::RecordInvalid, /Email has already been taken/)
    end

    it 'allows different emails' do
      create(:email_subscription, email: 'test1@example.com')

      expect {
        create(:email_subscription, email: 'test2@example.com')
      }.not_to raise_error
    end
  end

  describe 'email normalization' do
    it 'normalizes email to lowercase and strips whitespace' do
      subscription = create(:email_subscription, email: '  TEST@EXAMPLE.COM  ')
      expect(subscription.email).to eq('test@example.com')
    end
  end

  describe 'defaults' do
    it 'sets subscribed_at to current time if not provided' do
      subscription = build(:email_subscription, subscribed_at: nil)
      subscription.save!
      expect(subscription.subscribed_at).to be_within(1.second).of(Time.current)
    end
  end

  describe 'scopes' do
    let!(:opted_in) { create(:email_subscription, :opted_in) }
    let!(:opted_out) { create(:email_subscription, :opted_out) }

    describe '.opted_in' do
      it 'returns only subscriptions with marketing consent' do
        expect(EmailSubscription.opted_in).to include(opted_in)
        expect(EmailSubscription.opted_in).not_to include(opted_out)
      end
    end

    describe '.by_source' do
      let!(:trial_signup) { create(:email_subscription, source: 'trial_signup') }
      let!(:landing_page) { create(:email_subscription, source: 'landing_page') }

      it 'returns subscriptions by source' do
        expect(EmailSubscription.by_source('trial_signup')).to include(trial_signup)
        expect(EmailSubscription.by_source('trial_signup')).not_to include(landing_page)
      end
    end
  end

  describe 'optional user association' do
    it 'can exist without a user' do
      subscription = create(:email_subscription, user: nil)
      expect(subscription.user).to be_nil
    end

    it 'can be associated with a user' do
      user = create(:user)
      subscription = create(:email_subscription, user: user)
      expect(subscription.user).to eq(user)
    end
  end
end
