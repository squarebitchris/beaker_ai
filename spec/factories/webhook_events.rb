FactoryBot.define do
  factory :webhook_event do
    provider { 'stripe' }
    event_id { "evt_#{SecureRandom.hex(16)}" }
    event_type { 'checkout.session.completed' }
    payload { { id: event_id, type: event_type, data: { object: { id: 'cs_test' } } } }
    status { 'pending' }
    retries { 0 }

    trait :stripe do
      provider { 'stripe' }
      event_type { 'checkout.session.completed' }
      payload { { id: event_id, type: event_type, data: { object: { id: 'cs_test' } } } }
    end

    trait :twilio do
      provider { 'twilio' }
      event_id { "CA#{SecureRandom.hex(16)}" }
      event_type { 'call_status' }
      payload { { CallSid: event_id, CallStatus: 'completed' } }
    end

    trait :vapi do
      provider { 'vapi' }
      event_id { "call_#{SecureRandom.hex(16)}" }
      event_type { 'call.ended' }
      payload { { message: { id: event_id, type: event_type } } }
    end

    trait :processing do
      status { 'processing' }
      processed_at { Time.current }
    end

    trait :completed do
      status { 'completed' }
      processed_at { Time.current }
    end

    trait :failed do
      status { 'failed' }
      retries { 1 }
      error_message { 'Test error message' }
    end
  end
end
