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

    trait :with_captured_lead do
      captured {
        {
          name: Faker::Name.name,
          phone: "+1#{Faker::Number.number(digits: 10)}",
          email: Faker::Internet.email,
          goal: 'Request quote'
        }
      }
    end

    trait :lead_intake_scenario do
      scenario_slug { 'lead_intake' }
      intent { 'lead_intake' }
      with_captured_lead
    end

    trait :scheduling_scenario do
      scenario_slug { 'scheduling' }
      intent { 'scheduling' }
      captured do
        {
          name: Faker::Name.name,
          phone: "+1#{Faker::Number.number(digits: 10)}",
          preferred_date: '2025-11-15',
          preferred_time: '2:00 PM'
        }
      end
    end

    trait :with_lead do
      # Association will be defined when Lead model exists in Phase 5
      # For now, lead_id can be set to a UUID string for testing
      lead_id { SecureRandom.uuid }
    end
  end
end
