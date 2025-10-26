class TrialsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trial, only: [ :show, :call ]
  before_action :ensure_trial_owner, only: [ :show, :call ]

  def new
    @trial = Trial.new
    # View will be implemented in T011, basic scaffold for now
  end

  def create
    @trial = current_user.trials.build(trial_params)

    Rails.logger.info("[Trials] Attempting to save trial with params: #{trial_params}")
    Rails.logger.info("[Trials] Trial valid? #{@trial.valid?}")
    Rails.logger.info("[Trials] Trial errors: #{@trial.errors.full_messages}")

    if @trial.save
      CreateTrialAssistantJob.perform_later(@trial.id)
      redirect_to trial_path(@trial),
                  notice: "Creating your AI assistant. This usually takes 10-20 seconds..."
    else
      Rails.logger.info("[Trials] Save failed, errors: #{@trial.errors.full_messages}")
      flash.now[:alert] = "Please correct the errors below."
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("[Trials] Validation failed: #{e.message}")
    Sentry.capture_exception(e, extra: { user_id: current_user.id, params: trial_params })
    # Ensure @trial has validation errors for the view
    @trial = e.record
    flash.now[:alert] = "Please correct the errors below."
    render :new, status: :unprocessable_entity
  rescue => e
    Rails.logger.error("[Trials] Unexpected error: #{e.message}")
    Sentry.capture_exception(e, extra: { user_id: current_user.id, params: trial_params })
    flash[:alert] = "Something went wrong. Our team has been notified. Please try again."
    redirect_to new_trial_path
  end

  def show
    if params[:ready] == "1"
      # Polling endpoint - lightweight JSON response
      render json: {
        ready: @trial.ready?,
        status: @trial.status,
        calls_remaining: @trial.calls_remaining,
        expired: @trial.expired?
      }
    else
      # Regular show page with polling UI (T011)
    end
  end

  def call
    phone_number = params.require(:phone_number).strip

    # Validate US phone format (+1XXXXXXXXXX)
    unless phone_number.match?(/\A\+1\d{10}\z/)
      flash[:alert] = "Please enter a valid US phone number in format: +1XXXXXXXXXX"
      redirect_to trial_path(@trial)
      return
    end

    # Check trial is ready
    unless @trial.ready?
      flash[:alert] = "Your AI assistant is still being created. Please wait a moment."
      redirect_to trial_path(@trial)
      return
    end

    # Check trial expiration
    if @trial.expired?
      flash[:alert] = "This trial has expired. Please create a new one."
      redirect_to new_trial_path
      return
    end

    # Check call limits
    unless @trial.calls_remaining > 0
      flash[:alert] = "You've used all #{@trial.calls_limit} trial calls. Ready to upgrade?"
      redirect_to trial_path(@trial)
      return
    end

    # Check quiet hours
    unless QuietHours.allow?(phone_number)
      flash[:alert] = "Calls are only available 8 AM - 9 PM Central Time (TCPA compliance)."
      redirect_to trial_path(@trial)
      return
    end

    # Enqueue call
    StartTrialCallJob.perform_later(@trial.id, phone_number)

    flash[:notice] = "Calling #{phone_number} now... Answer your phone!"
    redirect_to trial_path(@trial)

  rescue ActionController::ParameterMissing
    flash[:alert] = "Phone number is required."
    redirect_to trial_path(@trial)
  rescue => e
    Rails.logger.error("[Trials] Call initiation failed: #{e.message}")
    Sentry.capture_exception(e, extra: {
      trial_id: @trial.id,
      user_id: current_user.id,
      phone_number: phone_number
    })
    flash[:alert] = "Unable to place call. Our team has been notified. Please try again."
    redirect_to trial_path(@trial)
  end

  private

  def set_trial
    @trial = Trial.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Trial not found."
    redirect_to new_trial_path
  end

  def ensure_trial_owner
    unless @trial.user_id == current_user.id
      flash[:alert] = "You don't have permission to access this trial."
      redirect_to new_trial_path
    end
  end

  def trial_params
    params.require(:trial).permit(
      :industry,
      :business_name,
      :scenario,
      :phone_e164
    )
  end
end
