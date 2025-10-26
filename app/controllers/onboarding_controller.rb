class OnboardingController < ApplicationController
  before_action :authenticate_user!, except: [ :cancel, :success, :status ]

  def success
    # Success page (no auth required)
  end

  def show
    @session_id = params[:session_id]

    unless @session_id&.start_with?("cs_")
      flash[:error] = "Invalid session ID."
      redirect_to new_trial_path and return
    end

    # Poll for business provisioning status
    # Phase 3: This will check if ConvertTrialToBusinessJob completed
  end

  def status
    session_id = params.require(:session_id)

    # Check if business was created for this checkout session
    # For now, return pending
    render json: {
      status: "pending",
      message: "Setting up your account..."
    }
  end
end
