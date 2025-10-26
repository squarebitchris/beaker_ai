# frozen_string_literal: true

module Voice
  class AudioPlayerComponentPreview < ViewComponent::Preview
    # Standard audio player with recording URL
    def default
      render(Voice::AudioPlayerComponent.new(
        recording_url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        call_id: 'call-123'
      ))
    end

    # Player that will attempt to load but may show error
    def with_invalid_url
      render(Voice::AudioPlayerComponent.new(
        recording_url: 'https://example.com/nonexistent.mp3',
        call_id: 'call-456'
      ))
    end

    # Player with short duration (< 1 minute)
    def short_duration
      render(Voice::AudioPlayerComponent.new(
        recording_url: 'https://www2.cs.uic.edu/~i101/SoundFiles/BabyElephantWalk60.wav',
        call_id: 'call-789'
      ))
    end

    # Player placeholder for testing (no actual audio)
    def placeholder
      render(Voice::AudioPlayerComponent.new(
        recording_url: 'https://example.com/placeholder.mp3',
        call_id: 'call-placeholder'
      ))
    end
  end
end
