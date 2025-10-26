FactoryBot.define do
  factory :phone_number do
    business
    e164 { "+1#{Faker::Number.number(digits: 10)}" }
    twilio_sid { "PN#{SecureRandom.hex(16)}" }
    country { "US" }
    area_code { e164[2..4] }
    capabilities { { voice: true, sms: true } }
  end
end
