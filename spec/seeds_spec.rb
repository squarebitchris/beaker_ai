require 'rails_helper'

RSpec.describe 'Seeds' do
  describe 'HVAC scenario template' do
    it 'creates the template idempotently' do
      # Run seeds twice to ensure idempotency
      Rails.application.load_seed
      Rails.application.load_seed

      template = ScenarioTemplate.find_by(key: 'hvac_lead_intake', active: true)
      expect(template).to be_present
      expect(template.version).to eq(1)
      expect(template.prompt_pack).to be_present
      expect(template.notes).to eq('HVAC lead intake scenario template for trial users')
    end

    it 'has correct prompt_pack structure' do
      Rails.application.load_seed

      template = ScenarioTemplate.find_by(key: 'hvac_lead_intake', active: true)
      prompt_pack = template.prompt_pack

      expect(prompt_pack).to have_key('system')
      expect(prompt_pack).to have_key('first_message')
      expect(prompt_pack).to have_key('tools')

      expect(prompt_pack['system']).to include('HVAC assistant')
      expect(prompt_pack['first_message']).to include('[COMPANY_NAME]')

      tools = prompt_pack['tools']
      expect(tools).to be_an(Array)
      expect(tools.first).to have_key('type')
      expect(tools.first).to have_key('function')
      expect(tools.first['function']['name']).to eq('capture_lead')
    end

    it 'only creates one active template per key' do
      Rails.application.load_seed

      count = ScenarioTemplate.where(key: 'hvac_lead_intake', active: true).count
      expect(count).to eq(1)
    end
  end
end
