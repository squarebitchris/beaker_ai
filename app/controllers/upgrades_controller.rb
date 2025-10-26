# frozen_string_literal: true

class UpgradesController < ApplicationController
  before_action :authenticate_user!

  def new
    @trial = Trial.find(params[:trial_id])

    # Track upgrade intent server-side
    track_upgrade_intent(@trial)

    # Phase 3: Redirect to Stripe checkout
    # For now, show coming soon message
  end

  private

  def track_upgrade_intent(trial)
    Rails.logger.info("[Upgrade] User #{current_user.id} clicked upgrade CTA for trial #{trial.id}")

    # Store in session for Phase 3 conversion attribution
    session[:upgrade_intent] = {
      trial_id: trial.id,
      timestamp: Time.current.iso8601
    }
  end
end
