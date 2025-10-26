# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Upgrade CTA Flow", type: :system do
  let(:user) { create(:user) }
  let(:trial) { create(:trial, :active, user: user) }
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

    # Should land on coming soon page
    expect(page).to have_content("Upgrade Coming Soon")
    expect(page).to have_content("Your own dedicated phone number")
    expect(page).to have_link("Back to Trial")
  end
end
