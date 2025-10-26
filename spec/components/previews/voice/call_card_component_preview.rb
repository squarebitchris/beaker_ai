# frozen_string_literal: true

module Voice
  class CallCardComponentPreview < ViewComponent::Preview
    def with_full_data
      call = Call.new(
        intent: 'lead_intake',
        duration_seconds: 185,
        started_at: 2.hours.ago,
        captured: {
          "name" => "Jane Smith",
          "phone" => "+15555551234",
          "email" => "jane@example.com",
          "goal" => "Request HVAC quote for home"
        },
        transcript: "Agent: Hi, this is Sarah from Smith HVAC. How can I help you today?\nCustomer: Hi, I need a quote for a new AC unit.\nAgent: I'd be happy to help with that. Can I get your name?\nCustomer: Sure, it's Jane Smith.",
        recording_url: "https://example.com/recording.mp3"
      )
      
      render(CallCardComponent.new(call: call))
    end

    def without_captured_data
      call = Call.new(
        intent: 'info',
        duration_seconds: 45,
        started_at: 1.hour.ago,
        captured: {},
        transcript: "Agent: Hi there!\nCustomer: Just calling to get your hours.",
        recording_url: nil
      )
      
      render(CallCardComponent.new(call: call))
    end

    def scheduling_intent
      call = Call.new(
        intent: 'scheduling',
        duration_seconds: 120,
        started_at: 30.minutes.ago,
        captured: {
          "name" => "John Doe",
          "phone" => "+15555559999",
          "preferred_date" => "2025-11-15",
          "preferred_time" => "2:00 PM"
        },
        transcript: "Agent: When would you like to schedule?\nCustomer: How about next Friday at 2pm?",
        recording_url: "https://example.com/recording2.mp3"
      )
      
      render(CallCardComponent.new(call: call))
    end

    def with_partial_captured_data
      call = Call.new(
        intent: 'info',
        duration_seconds: 90,
        started_at: 45.minutes.ago,
        captured: {
          "name" => "Bob Wilson",
          "phone" => "+15555557777"
          # Missing email and goal
        },
        transcript: "Agent: How can I assist you?\nCustomer: I have a question about pricing.",
        recording_url: "https://example.com/recording3.mp3"
      )
      
      render(CallCardComponent.new(call: call))
    end
  end
end

