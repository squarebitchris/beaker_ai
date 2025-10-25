FactoryBot.define do
  factory :call do
    association :callable, factory: :trial
    direction { 'outbound_trial' }
    to_e164 { "+1#{Faker::Number.number(digits: 10)}" }
    status { 'initiated' }

    trait :completed do
      status { 'completed' }
      duration_seconds { rand(30..300) }
      started_at { 5.minutes.ago }
      ended_at { 2.minutes.ago }
      vapi_call_id { "call_#{SecureRandom.hex(16)}" }
      twilio_call_sid { "CA#{SecureRandom.hex(16)}" }
    end

    trait :with_transcript do
      completed
      transcript { "Agent: Hi, this is Sarah. How can I help?\nCustomer: I need a quote." }
      extracted_lead { { name: 'John Doe', phone: '+15555551234', intent: 'quote' } }
    end

    trait :for_business do
      association :callable, factory: :business
      direction { 'inbound' }
    end
  end
end
