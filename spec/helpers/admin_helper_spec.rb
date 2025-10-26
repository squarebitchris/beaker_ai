require 'rails_helper'

RSpec.describe AdminHelper, type: :helper do
  describe '#mask_email' do
    it 'masks email addresses showing first character' do
      expect(helper.mask_email("john@example.com")).to eq("j***@example.com")
      expect(helper.mask_email("jane.doe@example.com")).to eq("j***@example.com")
      expect(helper.mask_email("test@domain.co.uk")).to eq("t***@domain.co.uk")
    end

    it 'handles single character local part' do
      expect(helper.mask_email("j@example.com")).to eq("j***@example.com")
    end

    it 'returns masked value for blank email' do
      expect(helper.mask_email("")).to eq("***")
      expect(helper.mask_email(nil)).to eq("***")
    end

    it 'handles malformed email gracefully' do
      expect(helper.mask_email("notanemail")).to eq("notanemail")
      expect(helper.mask_email("@missing.local")).to eq("@missing.local")
    end
  end

  describe '#mask_phone' do
    it 'masks phone numbers showing last 4 digits' do
      expect(helper.mask_phone("+15551234567")).to eq("***-***-4567")
      expect(helper.mask_phone("+12125551234")).to eq("***-***-1234")
    end

    it 'handles formatted phone numbers' do
      expect(helper.mask_phone("+1 (555) 123-4567")).to eq("***-***-4567")
      expect(helper.mask_phone("555-1234")).to eq("***-***-1234")
    end

    it 'returns masked value for blank phone' do
      expect(helper.mask_phone("")).to eq("***")
      expect(helper.mask_phone(nil)).to eq("***")
    end

    it 'returns masked value for short phone numbers' do
      expect(helper.mask_phone("123")).to eq("***")
      expect(helper.mask_phone("12")).to eq("***")
    end

    it 'handles phone numbers without country code' do
      expect(helper.mask_phone("5551234567")).to eq("***-***-4567")
    end
  end
end
