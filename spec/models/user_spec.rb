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
end
