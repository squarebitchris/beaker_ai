require 'rails_helper'

RSpec.describe BusinessOwnership, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:business) }
  end
  
  describe 'validations' do
    it 'validates uniqueness of user_id scoped to business_id' do
      user = create(:user)
      business = create(:business)
      
      create(:business_ownership, user: user, business: business)
      
      duplicate_ownership = build(:business_ownership, user: user, business: business)
      expect(duplicate_ownership).not_to be_valid
      expect(duplicate_ownership.errors[:user_id]).to include('has already been taken')
    end
    
    it 'allows same user to own multiple businesses' do
      user = create(:user)
      business1 = create(:business)
      business2 = create(:business)
      
      ownership1 = create(:business_ownership, user: user, business: business1)
      ownership2 = build(:business_ownership, user: user, business: business2)
      
      expect(ownership1).to be_valid
      expect(ownership2).to be_valid
    end
    
    it 'allows same business to be owned by multiple users' do
      user1 = create(:user)
      user2 = create(:user)
      business = create(:business)
      
      ownership1 = create(:business_ownership, user: user1, business: business)
      ownership2 = build(:business_ownership, user: user2, business: business)
      
      expect(ownership1).to be_valid
      expect(ownership2).to be_valid
    end
  end
end
