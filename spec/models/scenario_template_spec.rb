require 'rails_helper'

RSpec.describe ScenarioTemplate, type: :model do
  describe 'associations' do
    it { should have_many(:trials).dependent(:nullify) }
  end

  describe 'validations' do
    it { should validate_presence_of(:key) }
    it { should validate_presence_of(:version) }
    it { should validate_presence_of(:prompt_pack) }
    it { should validate_numericality_of(:version).is_greater_than(0) }
    it { should validate_inclusion_of(:active).in_array([ true, false ]) }
  end

  describe 'scopes' do
    let!(:active_template) { create(:scenario_template, active: true) }
    let!(:inactive_template) { create(:scenario_template, active: false) }

    describe '.active' do
      it 'returns only active templates' do
        expect(ScenarioTemplate.active).to include(active_template)
        expect(ScenarioTemplate.active).not_to include(inactive_template)
      end
    end
  end

  describe 'partial unique index' do
    it 'prevents duplicate active templates with same key' do
      create(:scenario_template, key: 'hvac_lead_intake', active: true)

      expect {
        create(:scenario_template, key: 'hvac_lead_intake', active: true)
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'allows multiple inactive templates with same key' do
      create(:scenario_template, key: 'hvac_lead_intake', active: false)

      expect {
        create(:scenario_template, key: 'hvac_lead_intake', active: false)
      }.not_to raise_error
    end

    it 'allows active and inactive templates with same key' do
      create(:scenario_template, key: 'hvac_lead_intake', active: true)

      expect {
        create(:scenario_template, key: 'hvac_lead_intake', active: false)
      }.not_to raise_error
    end
  end

  describe 'prompt_pack accessor methods' do
    let(:template) do
      create(:scenario_template, prompt_pack: {
        'system' => 'You are a helpful assistant.',
        'first_message' => 'Hello!',
        'tools' => [ { 'type' => 'function' } ]
      })
    end

    describe '#system_prompt' do
      it 'returns the system prompt' do
        expect(template.system_prompt).to eq('You are a helpful assistant.')
      end
    end

    describe '#first_message' do
      it 'returns the first message' do
        expect(template.first_message).to eq('Hello!')
      end
    end

    describe '#tools' do
      it 'returns the tools array' do
        expect(template.tools).to eq([ { 'type' => 'function' } ])
      end

      it 'returns empty array when tools is nil' do
        template.update!(prompt_pack: { 'system' => 'test', 'first_message' => 'hi' })
        expect(template.tools).to eq([])
      end
    end
  end
end
