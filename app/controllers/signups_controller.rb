class SignupsController < ApplicationController
  def new
    # Render signup form
  end

  def create
    email = params.require(:email).strip.downcase
    marketing_consent = params[:marketing_consent] == "1"

    # Create or find user
    user = User.find_or_initialize_by(email: email)
    user.save!

    # Create email subscription with consent tracking
    EmailSubscription.find_or_create_by(email: email) do |subscription|
      subscription.user = user
      subscription.marketing_consent = marketing_consent
      subscription.source = "trial_signup"
      subscription.subscribed_at = Time.current
      subscription.consent_ip = request.remote_ip
      subscription.consent_user_agent = request.user_agent
    end

    # Send magic link
    user.send_magic_link(false) # false for remember_me

    redirect_to root_path, notice: "Check your email for a magic link to continue."
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("[Signup] Failed to create user/subscription: #{e.message}")
    redirect_to new_signup_path, alert: "There was a problem with your signup. Please try again."
  rescue => e
    Rails.logger.error("[Signup] Unexpected error: #{e.message}")
    Sentry.capture_exception(e, extra: { email: email, ip: request.remote_ip })
    redirect_to new_signup_path, alert: "Something went wrong. Please try again."
  end

  private

  def extract_utm_params
    params.permit(:utm_source, :utm_medium, :utm_campaign, :utm_content, :utm_term).to_h
  end
end
