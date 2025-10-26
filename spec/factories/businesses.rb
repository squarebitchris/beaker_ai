FactoryBot.define do
  factory :business do
    name { Faker::Company.name }
    stripe_customer_id { "cus_#{SecureRandom.hex(12)}" }
    stripe_subscription_id { "sub_#{SecureRandom.hex(12)}" }
    plan { 'starter' }
    status { 'active' }
    calls_included { 100 }  # Explicitly set this since callback might not run in tests

    trait :pro_plan do
      plan { 'pro' }
      calls_included { 300 }  # Updated from 500 to protect margins
    end

    trait :with_owner do
      after(:create) do |business|
        user = create(:user)
        create(:business_ownership, business: business, user: user)
      end
    end

    trait :with_trial do
      association :trial
    end
  end
end
