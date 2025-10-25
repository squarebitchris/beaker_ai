FactoryBot.define do
  factory :trial do
    user
    industry { 'hvac' }
    business_name { Faker::Company.name }
    scenario { 'lead_intake' }
    phone_e164 { "+1#{Faker::Number.number(digits: 10)}" }
    status { 'pending' }
    calls_used { 0 }
    calls_limit { 3 }
    expires_at { 48.hours.from_now }

    trait :active do
      status { 'active' }
      vapi_assistant_id { "asst_#{SecureRandom.hex(12)}" }
    end

    trait :expired do
      status { 'expired' }
      expires_at { 1.hour.ago }
    end

    trait :with_calls do
      after(:create) do |trial|
        create_list(:call, 2, callable: trial)
      end
    end
  end
end
