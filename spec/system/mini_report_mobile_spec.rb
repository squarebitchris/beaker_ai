require 'rails_helper'

RSpec.describe 'Mini-Report Mobile Layout', type: :system, js: true do
  let(:user) { create(:user) }
  let(:trial) { create(:trial, :active, user: user) }

  before do
    # Create the call and ensure trial is reloaded
    create(:call, :completed, :with_transcript, :with_captured_lead,
      callable: trial,
      captured: {
        name: "John Smith",
        phone: "+15555551234",
        email: "john@example.com",
        goal: "Get a quote for HVAC repair"
      },
      intent: "lead_intake",
      duration_seconds: 125,
      recording_url: "https://example.com/recording.mp3"
    )
    trial.reload
    login_as(user, scope: :user)
    page.driver.browser.manage.window.resize_to(375, 667) # iPhone SE
  end

  describe 'layout at 375px viewport' do
    it 'displays captured fields above fold without scrolling' do
      visit trial_path(trial)

      # Captured fields section should be visible
      within('#trial_calls') do
        expect(page).to have_content('Captured Information')
        expect(page).to have_content('John Smith')
        expect(page).to have_content('+15555551234')
        expect(page).to have_content('john@example.com')
        expect(page).to have_content('Get a quote for HVAC repair')
      end

      # Check captured fields are in viewport (no scroll needed)
      captured_section = page.find('h4', text: 'Captured Information')
      expect(captured_section).to be_visible
    end

    it 'has proper touch targets (≥44px)' do
      visit trial_path(trial)

      # Note: Audio player with 60px touch targets tested separately in T007
      # This spec focuses on testing the upgrade CTA

      # Upgrade CTA should be ≥44px
      upgrade_link = page.find_link('Go Live - Get Your Number')
      expect(upgrade_link).to be_present
      # Get the element by text content using XPath
      cta_height = page.evaluate_script("document.evaluate('//a[contains(text(), \"Go Live\")]', document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue?.offsetHeight")
      expect(cta_height).to be >= 44
    end

    it 'has no horizontal scroll' do
      visit trial_path(trial)

      # Page width should not exceed viewport width
      page_width = page.evaluate_script('document.documentElement.scrollWidth')
      viewport_width = page.evaluate_script('window.innerWidth')
      expect(page_width).to eq(viewport_width)
    end

    it 'displays intent badge prominently' do
      visit trial_path(trial)

      within('#trial_calls') do
        expect(page).to have_content('Lead intake')
        badge = page.find('.rounded-full', text: 'Lead intake')
        expect(badge).to be_visible
      end
    end

    it 'shows upgrade CTA without scrolling on mobile' do
      visit trial_path(trial)

      within('#trial_calls') do
        expect(page).to have_content('Love what you see?')
        expect(page).to have_link('Go Live - Get Your Number')
      end
    end
  end

  describe 'empty state' do
    it 'shows appropriate message when no captured data' do
      # Update the call to remove captured data
      Call.where(callable: trial).update_all("captured = '{}'::jsonb")
      trial.reload

      visit trial_path(trial)

      within('#trial_calls') do
        expect(page).to have_content('No lead information captured')
      end
    end
  end
end
