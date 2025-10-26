require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:trials).dependent(:destroy) }
    it { should have_many(:business_ownerships).dependent(:destroy) }
    it { should have_many(:businesses).through(:business_ownerships) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'email normalization' do
    it 'normalizes email to lowercase' do
      user = create(:user, email: 'User@Example.COM')
      expect(user.email).to eq('user@example.com')
    end

    it 'strips whitespace' do
      user = create(:user, email: '  user@example.com  ')
      expect(user.email).to eq('user@example.com')
    end

    it 'removes + aliases to prevent abuse' do
      user1 = create(:user, email: 'user+test1@example.com')
      expect(user1.email).to eq('user@example.com')

      user2 = build(:user, email: 'user+test2@example.com')
      expect(user2).not_to be_valid
      expect(user2.errors[:email]).to include('has already been taken')
    end

    it 'treats user+alias@example.com and user@example.com as same' do
      create(:user, email: 'user@example.com')

      duplicate = build(:user, email: 'user+spam@example.com')
      expect(duplicate).not_to be_valid
    end
  end

  describe 'Devise modules' do
    it 'has magic_link_authenticatable module' do
      expect(User.devise_modules).to include(:magic_link_authenticatable)
    end
  end

  describe 'scopes' do
    let!(:admin_user) { create(:user, admin: true) }
    let!(:regular_user) { create(:user, admin: false) }

    it '.admins returns only admin users' do
      expect(User.admins).to include(admin_user)
      expect(User.admins).not_to include(regular_user)
    end
  end

  describe 'trial abuse prevention' do
    let(:user) { create(:user) }

    describe '#can_create_trial?' do
      it 'returns true when user has created less than 2 trials in 24 hours' do
        create(:trial, user: user, created_at: 2.hours.ago)

        expect(user.can_create_trial?).to be true
      end

      it 'returns false when user has created 2 trials in 24 hours' do
        create_list(:trial, 2, user: user, created_at: 1.hour.ago)

        expect(user.can_create_trial?).to be false
      end

      it 'allows new trials after 24 hours' do
        create_list(:trial, 2, user: user, created_at: 25.hours.ago)

        expect(user.can_create_trial?).to be true
      end
    end

    describe '.potential_abusers' do
      it 'finds users with more than 3 trials in past week' do
        abuser = create(:user)
        create_list(:trial, 4, user: abuser, created_at: 2.days.ago)

        normal_user = create(:user)
        create_list(:trial, 2, user: normal_user, created_at: 2.days.ago)

        expect(User.potential_abusers).to include(abuser)
        expect(User.potential_abusers).not_to include(normal_user)
      end

      it 'excludes old trials outside the time window' do
        user = create(:user)
        create_list(:trial, 4, user: user, created_at: 8.days.ago)

        expect(User.potential_abusers).not_to include(user)
      end

      it 'orders by trial count descending' do
        heavy_user = create(:user)
        create_list(:trial, 5, user: heavy_user, created_at: 1.day.ago)

        moderate_user = create(:user)
        create_list(:trial, 4, user: moderate_user, created_at: 1.day.ago)

        results = User.potential_abusers
        expect(results.first).to eq(heavy_user)
        expect(results.second).to eq(moderate_user)
      end
    end
  end
end
