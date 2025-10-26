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

    # Retrieve checkout session from Stripe to get subscription_id
    checkout_session = StripeClient.new.get_checkout_session(session_id: session_id)

    unless checkout_session
      render json: {
        status: "failed",
        message: "Checkout session not found. Please contact support."
      } and return
    end

    subscription_id = checkout_session.subscription

    unless subscription_id
      render json: {
        status: "pending",
        message: "Waiting for subscription to be created..."
      } and return
    end

    # Check if business was created (ConvertTrialToBusinessJob completed)
    business = Business.find_by(stripe_subscription_id: subscription_id)

    if business
      # Business is ready! Redirect to business dashboard
      render json: {
        status: "ready",
        redirect_url: dashboard_business_path(business),
        business_id: business.id,
        message: "Your account is ready!"
      }
    else
      # Still waiting for ConvertTrialToBusinessJob to complete
      render json: {
        status: "pending",
        message: "Setting up your account..."
      }
    end

  rescue => e
    Rails.logger.error("[Onboarding] Status check failed: #{e.message}")
    Sentry.capture_exception(e, extra: { session_id: session_id })

    render json: {
      status: "failed",
      message: "Unable to check status. Please contact support."
    }
  end
end
