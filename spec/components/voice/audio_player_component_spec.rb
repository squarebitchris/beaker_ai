# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Voice::AudioPlayerComponent, type: :component do
  describe 'rendering' do
    let(:recording_url) { 'https://example.com/recording.mp3' }

    it 'renders audio element with correct src' do
      render_inline(described_class.new(recording_url: recording_url))

      expect(page).to have_css('audio[preload="none"]')
      expect(page).to have_css("source[src='#{recording_url}']", count: 3)
    end

    it 'renders play button with ARIA label and 60px minimum height' do
      render_inline(described_class.new(recording_url: recording_url))

      play_button = page.find('button[aria-label="Play recording"]')
      expect(play_button).to be_present
      expect(play_button[:class]).to include('min-h-[60px]', 'min-w-[60px]')
      expect(play_button[:class]).to include('h-[60px]', 'w-[60px]')
    end

    it 'renders progress bar with role="slider"' do
      render_inline(described_class.new(recording_url: recording_url))

      progress_bar = page.find('input[role="slider"][aria-label="Seek audio"]')
      expect(progress_bar).to be_present
      expect(progress_bar[:type]).to eq('range')
      expect(progress_bar[:'aria-valuemin']).to eq('0')
      expect(progress_bar[:'aria-valuemax']).to eq('100')
    end

    it 'renders time displays' do
      render_inline(described_class.new(recording_url: recording_url))

      expect(page).to have_css('[data-audio-player-target="currentTime"]', text: '0:00')
      expect(page).to have_css('[data-audio-player-target="totalTime"]', text: '0:00')
    end

    it 'renders volume controls' do
      render_inline(described_class.new(recording_url: recording_url))

      volume_control = page.find('input[type="range"][aria-label="Volume"]')
      expect(volume_control).to be_present
      expect(volume_control[:min]).to eq('0')
      expect(volume_control[:max]).to eq('1')
      expect(volume_control[:step]).to eq('0.1')
    end

    it 'shows loading state on initial render' do
      render_inline(described_class.new(recording_url: recording_url))

      expect(page).to have_css('[data-audio-player-target="loadingOverlay"]')
      expect(page).to have_text('Loading audio...')
    end

    it 'has ARIA live region for announcements' do
      render_inline(described_class.new(recording_url: recording_url))

      live_region = page.find('[role="status"][aria-live="polite"]')
      expect(live_region).to be_present
      expect(live_region[:'aria-atomic']).to eq('true')
    end

    it 'has Stimulus controller attached' do
      render_inline(described_class.new(recording_url: recording_url))

      expect(page).to have_css('[data-controller="audio-player"]')
    end

    it 'sets recording URL as data-value' do
      render_inline(described_class.new(recording_url: recording_url))

      expect(page).to have_css('[data-audio-player-recording-url-value="' + recording_url + '"]', visible: false)
    end
  end

  describe 'valid_recording?' do
    it 'returns true for valid HTTP URL' do
      component = described_class.new(recording_url: 'https://example.com/audio.mp3')
      expect(component.valid_recording?).to be true
    end

    it 'returns true for valid HTTP URL' do
      component = described_class.new(recording_url: 'http://example.com/audio.mp3')
      expect(component.valid_recording?).to be true
    end

    it 'returns false for nil URL' do
      component = described_class.new(recording_url: nil)
      expect(component.valid_recording?).to be false
    end

    it 'returns false for empty string' do
      component = described_class.new(recording_url: '')
      expect(component.valid_recording?).to be false
    end

    it 'returns false for non-HTTP URL' do
      component = described_class.new(recording_url: 'ftp://example.com/audio.mp3')
      expect(component.valid_recording?).to be false
    end
  end

  describe 'formatted_time' do
    it 'formats seconds less than 60 as M:SS' do
      component = described_class.new(recording_url: 'https://example.com/audio.mp3')
      expect(component.formatted_time(45)).to eq('0:45')
    end

    it 'formats seconds greater than 60 as MM:SS' do
      component = described_class.new(recording_url: 'https://example.com/audio.mp3')
      expect(component.formatted_time(125)).to eq('2:05')
    end

    it 'formats hours correctly' do
      component = described_class.new(recording_url: 'https://example.com/audio.mp3')
      expect(component.formatted_time(3665)).to eq('1:01:05')
    end

    it 'handles zero' do
      component = described_class.new(recording_url: 'https://example.com/audio.mp3')
      expect(component.formatted_time(0)).to eq('0:00')
    end

    it 'handles nil' do
      component = described_class.new(recording_url: 'https://example.com/audio.mp3')
      expect(component.formatted_time(nil)).to eq('0:00')
    end

    it 'handles NaN' do
      component = described_class.new(recording_url: 'https://example.com/audio.mp3')
      expect(component.formatted_time(0.0 / 0.0)).to eq('0:00')
    end
  end

  describe 'ID generation' do
    it 'generates unique player IDs' do
      component1 = described_class.new(recording_url: 'https://example.com/1.mp3')
      component2 = described_class.new(recording_url: 'https://example.com/2.mp3')

      expect(component1.player_id).not_to eq(component2.player_id)
    end

    it 'generates consistent IDs within same instance' do
      component = described_class.new(recording_url: 'https://example.com/audio.mp3')

      # All IDs should start with "audio-player-" and include the suffix
      expect(component.audio_id).to match(/\Aaudio-player-[a-f0-9]{16}-audio\z/)
      expect(component.play_button_id).to match(/\Aaudio-player-[a-f0-9]{16}-play-button\z/)
      expect(component.progress_bar_id).to match(/\Aaudio-player-[a-f0-9]{16}-progress-bar\z/)
    end
  end

  describe 'with call_id provided' do
    it 'accepts optional call_id parameter' do
      component = described_class.new(
        recording_url: 'https://example.com/audio.mp3',
        call_id: 'call-123'
      )

      expect(component.call_id).to eq('call-123')
    end
  end
end
