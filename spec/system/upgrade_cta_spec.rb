# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Upgrade CTA Flow", type: :system do
  let(:user) { create(:user) }
  let(:trial) { create(:trial, :active, user: user) }
  let!(:starter_plan) { create(:stripe_plan, :starter) }
  let!(:pro_plan) { create(:stripe_plan, :pro) }
  let!(:call) { create(:call, :completed, :with_captured_lead, callable: trial,
      duration_seconds: 120,
      started_at: 5.minutes.ago,
      ended_at: 3.minutes.ago) }

  before do
    login_as(user, scope: :user)
  end

  it "navigates from call card to upgrade page" do
    visit trial_path(trial)

    expect(page).to have_content("Recent Calls")

    # Wait for the call card to render
    expect(page).to have_content("Go Live - Get Your Number")

    # Click the upgrade CTA
    click_link "Go Live - Get Your Number"

    # Should land on plan selection page (Phase 3 - fully functional)
    expect(page).to have_content("Choose Your Plan")
    # Verify plans are present by checking for plan buttons
    expect(page).to have_button("Choose Starter", wait: 2)
    expect(page).to have_button("Choose Pro", wait: 2)
    expect(page).to have_link("Back to Trial")
  end
end
