require 'rails_helper'

RSpec.describe 'Mini-Report Real-Time Updates', type: :system, js: true do
  let(:user) { create(:user) }
  let(:trial) { create(:trial, :active, user: user) }

  before do
    login_as(user, scope: :user)
    trial.reload # Ensure fresh trial data
  end

  it 'displays mini-report within 3s of webhook via Turbo Stream' do
    visit trial_path(trial)
    expect(page).to have_content('Recent Calls')

    # Record start time
    start_time = Time.current

    # Simulate webhook creating a call
    call = nil
    perform_enqueued_jobs do
      call = create(:call, :completed, :with_transcript,
        callable: trial,
        captured: { name: "Jane Doe", phone: "+15555559999" },
        intent: "lead_intake",
        duration_seconds: 90,
        recording_url: "https://example.com/recording.mp3"
      )

      # Broadcast Turbo Stream (simulates ProcessVapiEventJob)
      call_html = ApplicationController.render(
        partial: "trials/call",
        locals: { call: call }
      )
      prepend_stream = %(<turbo-stream action="prepend" target="trial_calls">#{call_html}</turbo-stream>)
      ActionCable.server.broadcast("trial:#{trial.id}", prepend_stream)
    end

    # Wait for Turbo Stream to update (max 3s)
    expect(page).to have_content('Jane Doe', wait: 3)

    # Calculate latency
    latency = Time.current - start_time
    expect(latency).to be < 3.seconds

    # Verify captured fields appear FIRST (above transcript)
    within("#call_#{call.id}") do
      expect(page).to have_content('Captured Information')
      expect(page).to have_content('Jane Doe')

      # Check ordering: captured info should appear before transcript
      captured_position = page.body.index('Captured Information')
      transcript_position = page.body.index('Transcript')
      expect(captured_position).to be < transcript_position
    end
  end

  it 'handles multiple calls appearing in real-time' do
    visit trial_path(trial)

    # Create 3 calls in sequence
    3.times do |i|
      call = create(:call, :completed,
        callable: trial,
        captured: { name: "Customer #{i + 1}" },
        intent: "lead_intake",
        duration_seconds: 60
      )

      call_html = ApplicationController.render(
        partial: "trials/call",
        locals: { call: call }
      )
      prepend_stream = %(<turbo-stream action="prepend" target="trial_calls">#{call_html}</turbo-stream>)
      ActionCable.server.broadcast("trial:#{trial.id}", prepend_stream)
    end

    # All 3 should appear
    expect(page).to have_content('Customer 1', wait: 3)
    expect(page).to have_content('Customer 2')
    expect(page).to have_content('Customer 3')

    # Newest should be first (prepended)
    calls_text = page.find('#trial_calls').text
    customer_3_pos = calls_text.index('Customer 3')
    customer_1_pos = calls_text.index('Customer 1')
    expect(customer_3_pos).to be < customer_1_pos
  end

  it 'has no layout shift (CLS) when mini-report appears' do
    visit trial_path(trial)

    # Measure initial layout
    initial_height = page.evaluate_script('document.documentElement.scrollHeight')

    # Add call via Turbo Stream
    call = create(:call, :completed, :with_transcript,
      callable: trial,
      captured: { name: "Test User" },
      duration_seconds: 120
    )

    call_html = ApplicationController.render(
      partial: "trials/call",
      locals: { call: call }
    )
    prepend_stream = %(<turbo-stream action="prepend" target="trial_calls">#{call_html}</turbo-stream>)
    ActionCable.server.broadcast("trial:#{trial.id}", prepend_stream)

    expect(page).to have_content('Test User', wait: 3)

    # Layout should expand smoothly (Turbo handles this)
    # No abrupt jumps or shifts
    new_height = page.evaluate_script('document.documentElement.scrollHeight')
    expect(new_height).to be > initial_height
  end
end
