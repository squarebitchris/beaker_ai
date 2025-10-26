FactoryBot.define do
  factory :email_subscription do
    email { Faker::Internet.email }
    marketing_consent { false }
    source { "trial_signup" }
    subscribed_at { Time.current }
    consent_ip { Faker::Internet.ip_v4_address }
    consent_user_agent { Faker::Internet.user_agent }

    trait :opted_in do
      marketing_consent { true }
    end

    trait :opted_out do
      marketing_consent { false }
    end

    trait :with_user do
      association :user
      email { user.email }
    end

    trait :from_landing_page do
      source { "landing_page" }
    end

    trait :from_referral do
      source { "referral" }
    end
  end
end
