# frozen_string_literal: true

module Voice
  class AudioPlayerComponent < ViewComponent::Base
    attr_reader :recording_url, :call_id

    def initialize(recording_url:, call_id: nil)
      @recording_url = recording_url
      @call_id = call_id
    end

    # Generate unique IDs for the player elements
    def player_id
      "audio-player-#{SecureRandom.hex(8)}"
    end

    def audio_id
      "#{player_id}-audio"
    end

    def play_button_id
      "#{player_id}-play-button"
    end

    def progress_bar_id
      "#{player_id}-progress-bar"
    end

    def current_time_id
      "#{player_id}-current-time"
    end

    def total_time_id
      "#{player_id}-total-time"
    end

    def volume_control_id
      "#{player_id}-volume-control"
    end

    def live_region_id
      "#{player_id}-live-region"
    end

    def loading_overlay_id
      "#{player_id}-loading-overlay"
    end

    def error_message_id
      "#{player_id}-error-message"
    end

    # Format seconds into MM:SS or HH:MM:SS format
    def formatted_time(seconds)
      return "0:00" if seconds.nil? || (seconds.is_a?(Float) && seconds.nan?)

      total_seconds = seconds.to_i
      hours = total_seconds / 3600
      minutes = (total_seconds % 3600) / 60
      secs = total_seconds % 60

      if hours > 0
        format("%d:%02d:%02d", hours, minutes, secs)
      else
        format("%d:%02d", minutes, secs)
      end
    end

    # Check if recording URL is valid
    def valid_recording?
      recording_url.present? && recording_url.match?(/\Ahttps?:\/\/.+/)
    end
  end
end
