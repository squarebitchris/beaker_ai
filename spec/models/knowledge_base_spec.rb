require 'rails_helper'

RSpec.describe KnowledgeBase, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:industry) }
    it { should validate_presence_of(:category) }
    it { should validate_presence_of(:content) }

    it 'validates industry is in allowed list' do
      kb = build(:knowledge_base, industry: 'invalid')
      expect(kb).not_to be_valid
      expect(kb.errors[:industry]).to include(/not included in the list/)
    end

    it 'validates category is in allowed list' do
      kb = build(:knowledge_base, category: 'invalid')
      expect(kb).not_to be_valid
      expect(kb.errors[:category]).to include(/not included in the list/)
    end

    it 'validates priority is a non-negative integer' do
      kb = build(:knowledge_base, priority: -1)
      expect(kb).not_to be_valid
      expect(kb.errors[:priority]).to include(/must be greater than or equal to 0/)
    end
  end

  describe 'scopes' do
    let!(:active_hvac) { create(:knowledge_base, industry: 'hvac', active: true) }
    let!(:inactive_hvac) { create(:knowledge_base, industry: 'hvac', active: false) }
    let!(:active_gym) { create(:knowledge_base, industry: 'gym', active: true) }

    it '.active returns only active entries' do
      expect(KnowledgeBase.active).to include(active_hvac, active_gym)
      expect(KnowledgeBase.active).not_to include(inactive_hvac)
    end

    it '.for_industry filters by industry' do
      expect(KnowledgeBase.for_industry('hvac')).to include(active_hvac, inactive_hvac)
      expect(KnowledgeBase.for_industry('hvac')).not_to include(active_gym)
    end

    it '.by_category filters by category' do
      pricing_entry = create(:knowledge_base, category: 'pricing')
      services_entry = create(:knowledge_base, category: 'services')

      expect(KnowledgeBase.by_category('pricing')).to include(pricing_entry)
      expect(KnowledgeBase.by_category('pricing')).not_to include(services_entry)
    end

    it '.ordered sorts by priority desc, then created_at asc' do
      # Create with specific timestamps to ensure ordering
      travel_to Time.zone.parse('2025-01-01 00:00:00') do
        low_priority = create(:knowledge_base, priority: 1)
        sleep 0.1 # Ensure different timestamps
        medium_priority = create(:knowledge_base, priority: 5)
        sleep 0.1
        high_priority = create(:knowledge_base, priority: 10)

        ordered = KnowledgeBase.where(id: [ low_priority.id, medium_priority.id, high_priority.id ]).ordered.to_a
        expect(ordered).to eq([ high_priority, medium_priority, low_priority ])
      end
    end

    it '.for_assistant returns active entries for industry, ordered' do
      travel_to Time.zone.parse('2025-01-01 00:00:00') do
        high = create(:knowledge_base, industry: 'hvac', active: true, priority: 10)
        sleep 0.1
        low = create(:knowledge_base, industry: 'hvac', active: true, priority: 1)
        sleep 0.1
        inactive = create(:knowledge_base, industry: 'hvac', active: false, priority: 5)

        results = KnowledgeBase.where(id: [ high.id, low.id ]).for_assistant('hvac').to_a
        expect(results).to eq([ high, low ])
        expect(results).not_to include(inactive)
      end
    end
  end

  describe 'constants' do
    it 'defines CATEGORIES' do
      expect(KnowledgeBase::CATEGORIES).to eq(%w[pricing services hours faq general])
    end

    it 'defines INDUSTRIES' do
      expect(KnowledgeBase::INDUSTRIES).to eq(%w[hvac gym dental])
    end
  end
end
