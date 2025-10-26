require 'rails_helper'

RSpec.describe PhoneNumber, type: :model do
  describe 'associations' do
    it { should belong_to(:business) }
  end

  describe 'validations' do
    subject { build(:phone_number) }

    it { should validate_presence_of(:e164) }
    it { should validate_presence_of(:twilio_sid) }
    it { should validate_uniqueness_of(:e164).case_insensitive }
    it { should validate_uniqueness_of(:twilio_sid) }

    it 'validates E.164 format' do
      phone = build(:phone_number, e164: 'invalid')
      expect(phone).not_to be_valid
      expect(phone.errors[:e164]).to include(/E.164 format/)
    end

    it 'allows valid E.164 format' do
      phone = build(:phone_number, e164: '+15551234567')
      expect(phone).to be_valid
    end
  end

  describe '#formatted' do
    it 'returns formatted phone number' do
      phone = build(:phone_number, e164: '+15551234567')
      expect(phone.formatted).to eq('(555) 123-4567')
    end
  end

  describe 'scopes' do
    let!(:active_business) { create(:business, status: :active) }
    let!(:inactive_business) { create(:business, status: :canceled) }

    before do
      create(:phone_number, business: active_business)
      create(:phone_number, business: inactive_business)
    end

    it 'returns only phone numbers for active businesses' do
      active_phones = PhoneNumber.active
      expect(active_phones.count).to eq(1)
      expect(active_phones.first.business.status).to eq('active')
    end
  end
end
