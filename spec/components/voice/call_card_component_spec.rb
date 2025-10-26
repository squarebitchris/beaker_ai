# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Voice::CallCardComponent, type: :component do
  let(:trial) { create(:trial) }

  describe 'with captured lead data' do
    let(:call) do
      create(:call, :completed, :with_captured_lead,
        callable: trial,
        intent: 'lead_intake',
        duration_seconds: 150,
        transcript: "Agent: Hi there!\nCustomer: I need help.",
        recording_url: "https://example.com/recording.mp3"
      )
    end

    it 'renders captured fields first' do
      render_inline(described_class.new(call: call))

      expect(page).to have_text("Captured Information")
      expect(page).to have_text("Name")
      expect(page).to have_text("Phone")
      expect(page).to have_text("Email")
      expect(page).to have_text("Goal")
    end

    it 'displays intent badge' do
      render_inline(described_class.new(call: call))

      expect(page).to have_text("Lead intake") # humanize converts to lowercase
    end

    it 'displays formatted duration' do
      render_inline(described_class.new(call: call))

      expect(page).to have_text("2:30")
    end

    it 'displays transcript' do
      render_inline(described_class.new(call: call))

      expect(page).to have_text("Transcript")
      expect(page).to have_text("Agent: Hi there!")
    end

    it 'displays recording placeholder' do
      render_inline(described_class.new(call: call))

      expect(page).to have_text("Recording")
      expect(page).to have_link("Listen in new tab", href: call.recording_url)
    end
  end

  describe 'without captured data' do
    let(:call) do
      create(:call, :completed,
        callable: trial,
        duration_seconds: 60,
        captured: {}
      )
    end

    it 'shows empty state for captured data' do
      render_inline(described_class.new(call: call))

      expect(page).to have_text("No lead information captured")
    end
  end

  describe 'without recording' do
    let(:call) do
      create(:call, :completed,
        callable: trial,
        recording_url: nil
      )
    end

    it 'does not show recording section' do
      render_inline(described_class.new(call: call))

      expect(page).not_to have_text("Recording")
    end
  end

  describe 'without transcript' do
    let(:call) do
      create(:call, :completed,
        callable: trial,
        transcript: nil
      )
    end

    it 'does not show transcript section' do
      render_inline(described_class.new(call: call))

      expect(page).not_to have_text("Transcript")
    end
  end

  describe 'intent badge variants' do
    it 'uses success variant for lead_intake' do
      call = create(:call, callable: trial, intent: 'lead_intake')
      component = described_class.new(call: call)

      expect(component.intent_badge_variant).to eq(:success)
    end

    it 'uses default variant for scheduling' do
      call = create(:call, callable: trial, intent: 'scheduling')
      component = described_class.new(call: call)

      expect(component.intent_badge_variant).to eq(:default)
    end

    it 'uses secondary variant for other intents' do
      call = create(:call, callable: trial, intent: 'info')
      component = described_class.new(call: call)

      expect(component.intent_badge_variant).to eq(:secondary)
    end
  end

  describe '#badge_classes' do
    it 'returns correct classes for success variant' do
      call = create(:call, callable: trial, intent: 'lead_intake')
      component = described_class.new(call: call)

      expect(component.badge_classes).to include('bg-green-100', 'text-green-800')
    end

    it 'returns correct classes for default variant' do
      call = create(:call, callable: trial, intent: 'scheduling')
      component = described_class.new(call: call)

      expect(component.badge_classes).to include('bg-blue-100', 'text-blue-800')
    end

    it 'returns correct classes for secondary variant' do
      call = create(:call, callable: trial, intent: 'info')
      component = described_class.new(call: call)

      expect(component.badge_classes).to include('bg-gray-100', 'text-gray-800')
    end
  end

  describe '#formatted_duration' do
    it 'formats duration as MM:SS' do
      call = create(:call, callable: trial, duration_seconds: 185)
      component = described_class.new(call: call)

      expect(component.formatted_duration).to eq("3:05")
    end

    it 'handles zero seconds' do
      call = create(:call, callable: trial, duration_seconds: 59)
      component = described_class.new(call: call)

      expect(component.formatted_duration).to eq("0:59")
    end

    it 'returns N/A when duration is nil' do
      call = create(:call, callable: trial, duration_seconds: nil)
      component = described_class.new(call: call)

      expect(component.formatted_duration).to eq("N/A")
    end
  end
end
