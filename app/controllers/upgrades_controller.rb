# frozen_string_literal: true

class UpgradesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trial
  before_action :ensure_trial_owner
  before_action :validate_trial_eligible

  def new
    # Show plan selection page with pricing cards
    @plans = StripePlan.active.order(:base_price_cents)
  end

  def create
    plan_name = params.require(:plan)
    stripe_plan = StripePlan.for_plan(plan_name)

    unless stripe_plan
      flash[:error] = "Invalid plan selected."
      redirect_to new_upgrade_path(trial_id: @trial.id) and return
    end

    # Track upgrade intent
    track_upgrade_intent(@trial, plan_name)

    # Create checkout session with idempotency
    idempotency_key = "checkout:#{current_user.id}:#{@trial.id}"

    checkout_session = StripeClient.new.create_checkout_session(
      price_id: stripe_plan.stripe_price_id,
      customer_email: current_user.email,
      metadata: {
        trial_id: @trial.id,
        user_id: current_user.id,
        plan: plan_name,
        business_name: @trial.business_name
      },
      idempotency_key: idempotency_key
    )

    redirect_to checkout_session.url, allow_other_host: true

  rescue Stripe::StripeError => e
    Sentry.capture_exception(e, extra: { trial_id: @trial.id, plan: plan_name })
    flash[:error] = "Unable to start checkout. Please try again."
    redirect_to new_upgrade_path(trial_id: @trial.id)
  rescue ApiClientBase::CircuitOpenError => e
    Sentry.capture_exception(e)
    flash[:error] = "Payment system temporarily unavailable. Please try again in a few minutes."
    redirect_to trial_path(@trial)
  end

  private

  def set_trial
    @trial = Trial.find(params[:trial_id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Trial not found."
    redirect_to new_trial_path
  end

  def ensure_trial_owner
    unless @trial.user_id == current_user.id
      flash[:alert] = "You don't have permission to upgrade this trial."
      redirect_to new_trial_path
    end
  end

  def validate_trial_eligible
    if @trial.status == "converted"
      flash[:alert] = "This trial has already been converted to a paid plan."
      redirect_to trial_path(@trial)
    elsif @trial.expired?
      flash[:alert] = "This trial has expired. Please create a new trial."
      redirect_to new_trial_path
    elsif !@trial.ready?
      flash[:alert] = "Please wait for your trial assistant to be ready before upgrading."
      redirect_to trial_path(@trial)
    end
  end

  def track_upgrade_intent(trial, plan_name)
    Rails.logger.info("[Upgrade] User #{current_user.id} initiated checkout for trial #{trial.id}, plan: #{plan_name}")

    session[:upgrade_intent] = {
      trial_id: trial.id,
      plan: plan_name,
      timestamp: Time.current.iso8601
    }
  end
end
