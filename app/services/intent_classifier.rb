# frozen_string_literal: true

# Classify call intent from Vapi function calls and transcript
class IntentClassifier
  def self.call(call_payload, default_slug = nil)
    call_payload = (call_payload || {}).with_indifferent_access

    # Tier 1: Function call classification (preferred)
    funcs = Array(call_payload[:functionCalls])
    return "lead_intake" if funcs.any? { |f| f["name"] == "capture_lead" }
    return "scheduling" if funcs.any? { |f| f["name"] == "offer_times" }

    # Tier 2: Transcript keyword fallback
    transcript = Array(call_payload[:transcript])
    msg = transcript.map { |t| t["message"]&.downcase }.compact.join(" ")

    return "scheduling" if msg.match?(/\b(book|appointment)\b/)
    return "lead_intake" if msg.match?(/\b(interested|join)\b/)

    # Tier 3: Default fallback
    default_slug.presence || "info"
  end
end
