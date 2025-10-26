require 'rails_helper'

RSpec.describe KbGenerator do
  describe '.for_industry' do
    let!(:hvac_entries) do
      [
        create(:knowledge_base, industry: 'hvac', content: 'Fact 1', active: true, priority: 10),
        create(:knowledge_base, industry: 'hvac', content: 'Fact 2', active: true, priority: 5)
      ]
    end
    let!(:gym_entry) { create(:knowledge_base, industry: 'gym', content: 'Gym fact', active: true) }
    let!(:inactive_hvac) { create(:knowledge_base, industry: 'hvac', content: 'Inactive', active: false) }

    it 'returns active KB entries for the specified industry' do
      facts = described_class.for_industry(:hvac)

      expect(facts).to be_an(Array)
      expect(facts.size).to eq(2)
      expect(facts).to include('Fact 1', 'Fact 2')
      expect(facts).not_to include('Gym fact', 'Inactive')
    end

    it 'returns entries ordered by priority' do
      facts = described_class.for_industry(:hvac)

      expect(facts.first).to eq('Fact 1')  # priority 10
      expect(facts.second).to eq('Fact 2')  # priority 5
    end

    it 'returns empty array for industry with no entries' do
      facts = described_class.for_industry(:dental)

      expect(facts).to eq([])
    end

    it 'accepts industry as string or symbol' do
      expect(described_class.for_industry('hvac')).to eq(described_class.for_industry(:hvac))
    end
  end

  describe '.to_prompt_context' do
    let!(:hvac_entries) do
      [
        create(:knowledge_base, industry: 'hvac', content: 'Emergency services 24/7', active: true, priority: 10),
        create(:knowledge_base, industry: 'hvac', content: 'Free estimates', active: true, priority: 5)
      ]
    end

    it 'formats KB entries as bullet list with header' do
      context = described_class.to_prompt_context(:hvac)

      expect(context).to include("## Business Knowledge")
      expect(context).to include("- Emergency services 24/7")
      expect(context).to include("- Free estimates")
    end

    it 'returns empty string when no entries exist' do
      context = described_class.to_prompt_context(:dental)

      expect(context).to eq("")
    end

    it 'includes newlines for proper formatting' do
      context = described_class.to_prompt_context(:hvac)

      expect(context).to start_with("\n\n")
      expect(context).to include("\n- ")
    end

    it 'orders facts by priority' do
      context = described_class.to_prompt_context(:hvac)

      lines = context.split("\n").reject(&:blank?)
      expect(lines[1]).to include("Emergency services 24/7")  # Higher priority first
      expect(lines[2]).to include("Free estimates")
    end
  end

  describe '.by_category' do
    before do
      create(:knowledge_base, industry: 'hvac', category: 'pricing', content: 'Price 1', active: true)
      create(:knowledge_base, industry: 'hvac', category: 'pricing', content: 'Price 2', active: true)
      create(:knowledge_base, industry: 'hvac', category: 'services', content: 'Service 1', active: true)
      create(:knowledge_base, industry: 'gym', category: 'pricing', content: 'Gym price', active: true)
    end

    it 'returns hash grouped by category' do
      result = described_class.by_category(:hvac)

      expect(result).to be_a(Hash)
      expect(result.keys).to match_array([ 'pricing', 'services' ])
    end

    it 'includes all entries for each category' do
      result = described_class.by_category(:hvac)

      expect(result['pricing']).to contain_exactly('Price 1', 'Price 2')
      expect(result['services']).to contain_exactly('Service 1')
    end

    it 'does not include entries from other industries' do
      result = described_class.by_category(:hvac)

      expect(result['pricing']).not_to include('Gym price')
    end

    it 'returns empty hash when no entries exist' do
      result = described_class.by_category(:dental)

      expect(result).to eq({})
    end
  end
end
