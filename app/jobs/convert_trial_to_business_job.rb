# frozen_string_literal: true

class ConvertTrialToBusinessJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(user_id:, trial_id:, stripe_customer_id:, stripe_subscription_id:, plan:, business_name:)
    user = User.find(user_id)
    trial = Trial.find(trial_id)

    # Idempotency: prevent duplicate businesses if webhook retries
    if Business.exists?(stripe_subscription_id: stripe_subscription_id)
      Rails.logger.info("[ConvertTrialToBusinessJob] Already converted: subscription=#{stripe_subscription_id}")
      return
    end

    ActiveRecord::Base.transaction do
      # 1. Clone the trial's assistant config (remove time cap for paid)
      assistant_config = build_business_assistant_config(trial, business_name)

      # 2. Create paid assistant in Vapi (no time cap)
      vapi_response = VapiClient.new.create_assistant(config: assistant_config)

      Rails.logger.info("[ConvertTrialToBusinessJob] Created Vapi assistant #{vapi_response['id']}")

      # 3. Create Business record with Stripe IDs and assistant
      stripe_plan = StripePlan.for_plan(plan)
      business = Business.create!(
        name: business_name || trial.business_name,
        plan: plan,
        status: "active",
        stripe_customer_id: stripe_customer_id,
        stripe_subscription_id: stripe_subscription_id,
        vapi_assistant_id: vapi_response["id"],
        trial: trial,
        calls_included: stripe_plan&.calls_included || 100,
        calls_used_this_period: 0
      )

      # 4. Link user to business via ownership
      BusinessOwnership.create!(
        user: user,
        business: business
      )

      # 5. Mark trial as converted
      trial.update!(status: "converted")

      Rails.logger.info("[ConvertTrialToBusinessJob] Created business #{business.id} for trial #{trial_id}")

      # 6. Send "Agent Ready" email
      begin
        BusinessMailer.agent_ready(business.id).deliver_later
        Rails.logger.info("[ConvertTrialToBusinessJob] Agent ready email queued for business #{business.id}")
      rescue => e
        # Don't fail the job if email fails, but track it
        Sentry.capture_exception(e, extra: { business_id: business.id, user_email: user.email })
        Rails.logger.error("[ConvertTrialToBusinessJob] Failed to queue agent ready email: #{e.message}")
      end

      business
    end

  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error("[ConvertTrialToBusinessJob] Record not found: #{e.message}")
    Sentry.capture_exception(e, extra: {
      user_id: user_id,
      trial_id: trial_id,
      stripe_subscription_id: stripe_subscription_id
    })
    raise

  rescue => e
    Rails.logger.error("[ConvertTrialToBusinessJob] Failed: #{e.message}")
    Rails.logger.error("[ConvertTrialToBusinessJob] Backtrace: #{e.backtrace.first(10).join("\n")}")
    Sentry.capture_exception(e, extra: {
      user_id: user_id,
      trial_id: trial_id,
      stripe_subscription_id: stripe_subscription_id,
      plan: plan
    })
    raise
  end

  private

  def build_business_assistant_config(trial, business_name)
    # Use the trial's stored assistant_config if available
    if trial.assistant_config.present?
      config = trial.assistant_config.deep_dup
    else
      # Fallback: rebuild from scenario template (shouldn't happen but safety net)
      template = ScenarioTemplate.active.find_by!(key: "#{trial.industry}_lead_intake")
      persona = {
        business_name: trial.business_name,
        industry: trial.industry,
        scenario: trial.scenario
      }
      kb_context = KbGenerator.to_prompt_context(trial.industry)
      prompt_data = PromptBuilder.call(
        template: template.prompt_pack,
        persona: persona,
        kb: { kb_context: kb_context }
      )

      config = {
        name: "#{business_name || trial.business_name} Assistant",
        system_prompt: prompt_data[:system] + kb_context,
        first_message: prompt_data[:first_message],
        functions: prompt_data[:tools] || [],
        voice_id: "rachel",
        model: "gpt-4o-mini",
        temperature: 0.7,
        max_duration_seconds: 120
      }
    end

    # Paid assistants have no time limits
    config[:max_duration_seconds] = nil

    # Update name for paid account
    config[:name] = "#{business_name || trial.business_name} Assistant"

    # Update webhook URL for business webhooks (Phase 4)
    config[:server_url] = "#{ENV.fetch('APP_URL', 'http://localhost:3000')}/webhooks/vapi"

    # Update metadata to reflect business context
    config[:metadata] = {
      business_name: business_name || trial.business_name,
      industry: trial.industry,
      trial_id: trial.id
    }

    config
  end
end
