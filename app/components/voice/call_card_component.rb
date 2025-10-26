# frozen_string_literal: true

module Voice
  class CallCardComponent < ViewComponent::Base
    attr_reader :call_record

  def initialize(call:, show_audio: true)
    @call_record = call
    @show_audio = show_audio
  end

  def trial_id
    return nil unless call_record.callable_type == "Trial"
    call_record.callable_id
  end

  def show_upgrade_cta?
    trial_id.present?
  end

  def captured_fields
      {
        "Name" => call_record.captured_name,
        "Phone" => call_record.captured_phone,
        "Email" => call_record.captured_email,
        "Goal" => call_record.captured_goal
      }.compact
    end

    def has_captured_data?
      captured_fields.any?
    end

    def intent_badge_variant
      case call_record.intent
      when "lead_intake" then :success
      when "scheduling" then :default
      when "info" then :secondary
      else :secondary
      end
    end

    def intent_label
      call_record.intent&.humanize || "Other"
    end

    def badge_classes
      case intent_badge_variant
      when :success
        "bg-green-100 text-green-800"
      when :default
        "bg-blue-100 text-blue-800"
      when :secondary
        "bg-gray-100 text-gray-800"
      else
        "bg-gray-100 text-gray-800"
      end
    end

    def formatted_duration
      return "N/A" unless call_record.duration_seconds
      minutes = call_record.duration_seconds / 60
      seconds = call_record.duration_seconds % 60
      "%d:%02d" % [ minutes, seconds ]
    end

    def formatted_timestamp
      return "N/A" unless call_record.started_at
      call_record.started_at.strftime("%b %d, %I:%M %p")
    end

    def has_recording?
      call_record.recording_url.present?
    end

    def has_transcript?
      call_record.transcript.present?
    end
  end
end
