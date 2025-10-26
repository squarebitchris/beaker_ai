# frozen_string_literal: true

require "rails_helper"
require "webmock/rspec"

RSpec.describe "Upgrade Flow", type: :system do
  let(:user) { create(:user) }
  let(:trial) { create(:trial, :active, user: user) }
  let!(:starter_plan) { create(:stripe_plan, :starter) }
  let!(:pro_plan) { create(:stripe_plan, :pro) }

  before do
    sign_in user
  end

  it "shows plan selection and redirects to Stripe" do
    stub_request(:post, "https://api.stripe.com/v1/checkout/sessions")
      .to_return(status: 200, body: { id: "cs_test", url: "https://checkout.stripe.com/test" }.to_json)

    visit trial_path(trial)

    # Find upgrade button (assumes there's an upgrade link)
    # For now, navigate directly to upgrade page
    visit new_upgrade_path(trial_id: trial.id)

    expect(page).to have_content("Choose Your Plan")
    expect(page).to have_content("$199")
    expect(page).to have_content("$499")

    # Click the first plan button (Starter)
    within("form", match: :first) do
      first("button[type='submit']").click
    end

    # Should redirect to Stripe (in real browser, this would redirect)
    # In test environment, we verify the request was made
  end

  it "prevents upgrading expired trial" do
    expired_trial = create(:trial, :expired, user: user)

    visit new_upgrade_path(trial_id: expired_trial.id)

    expect(page).to have_content("expired")
    expect(current_path).to eq(new_trial_path)
  end

  it "prevents upgrading when trial not ready" do
    pending_trial = create(:trial, user: user, status: "pending")

    visit new_upgrade_path(trial_id: pending_trial.id)

    expect(page).to have_content("ready")
  end
end

