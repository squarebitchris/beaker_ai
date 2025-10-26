FactoryBot.define do
  factory :knowledge_base do
    industry { 'hvac' }
    category { 'services' }
    content { 'Sample knowledge base entry for testing' }
    priority { 5 }
    active { true }

    trait :pricing do
      category { 'pricing' }
      content { 'Pricing information for services' }
    end

    trait :services do
      category { 'services' }
      content { 'Services offered by the business' }
    end

    trait :hours do
      category { 'hours' }
      content { 'Business hours and availability' }
    end

    trait :faq do
      category { 'faq' }
      content { 'Frequently asked question answer' }
    end

    trait :high_priority do
      priority { 10 }
    end

    trait :low_priority do
      priority { 0 }
    end

    trait :inactive do
      active { false }
    end

    trait :hvac do
      industry { 'hvac' }
    end

    trait :gym do
      industry { 'gym' }
    end

    trait :dental do
      industry { 'dental' }
    end
  end
end
