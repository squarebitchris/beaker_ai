FactoryBot.define do
  factory :stripe_plan do
    sequence(:plan_name) { |n| %w[starter pro][n % 2] }
    sequence(:stripe_price_id) { |n| "price_test_#{n.to_s.rjust(24, "0")}" }
    base_price_cents { 199_00 }
    calls_included { 100 }
    overage_cents_per_call { 150 }
    active { true }

    trait :starter do
      plan_name { "starter" }
      base_price_cents { 199_00 }
      calls_included { 100 }
      overage_cents_per_call { 150 }
    end

    trait :pro do
      plan_name { "pro" }
      base_price_cents { 499_00 }
      calls_included { 300 }
      overage_cents_per_call { 125 }
    end

    trait :inactive do
      active { false }
    end

    trait :with_placeholder do
      stripe_price_id { "price_starter_PLACEHOLDER" }
    end
  end
end
