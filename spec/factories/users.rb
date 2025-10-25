FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    
    trait :with_recent_login do
      current_sign_in_at { 5.minutes.ago }
    end
  end
end
