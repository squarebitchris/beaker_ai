class CreateTrialAssistantJob < ApplicationJob
  queue_as :default

  def perform(trial_id)
    trial = Trial.find(trial_id)

    # Idempotency check - don't recreate if assistant exists
    if trial.vapi_assistant_id.present?
      Rails.logger.info("[CreateTrialAssistantJob] Trial #{trial_id} already has assistant #{trial.vapi_assistant_id}, skipping")
      return
    end

    # Validate trial state
    unless trial.pending? && !trial.expired?
      Rails.logger.warn("[CreateTrialAssistantJob] Trial #{trial_id} not in valid state: status=#{trial.status}, expired=#{trial.expired?}")
      return
    end

    # Build assistant configuration
    assistant_config = build_assistant_config(trial)

    # Create assistant via Vapi
    vapi_response = VapiClient.new.create_assistant(config: assistant_config)

    # Update trial with assistant ID
    trial.update!(
      vapi_assistant_id: vapi_response["id"],
      assistant_config: assistant_config,
      status: "active"
    )

    Rails.logger.info("[CreateTrialAssistantJob] Created assistant #{vapi_response['id']} for trial #{trial_id}")

  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error("[CreateTrialAssistantJob] Trial #{trial_id} not found: #{e.message}")
    Sentry.capture_exception(e, extra: { trial_id: trial_id })
    raise
  rescue => e
    Rails.logger.error("[CreateTrialAssistantJob] Failed for trial #{trial_id}: #{e.message}")
    Sentry.capture_exception(e, extra: { trial_id: trial_id })
    raise
  end

  private

  def build_assistant_config(trial)
    # Get scenario template
    template = ScenarioTemplate.active.find_by!(key: "#{trial.industry}_lead_intake")

    # Build persona data from trial
    persona = {
      business_name: trial.business_name,
      industry: trial.industry,
      scenario: trial.scenario
    }

    # Generate KB context for this industry
    kb_context = KbGenerator.to_prompt_context(trial.industry)

    # Use PromptBuilder to merge template + persona + KB
    prompt_data = PromptBuilder.call(
      template: template.prompt_pack,
      persona: persona,
      kb: { kb_context: kb_context }
    )

    # Build Vapi assistant config with correct API structure
    {
      name: "#{trial.business_name} Assistant",
      system_prompt: prompt_data[:system] + kb_context,
      first_message: prompt_data[:first_message],
      functions: prompt_data[:tools] || [],
      voice_id: "rachel",
      model: "gpt-4o-mini",
      temperature: 0.7,
      max_duration_seconds: 120, # 2 minute limit for trials
      silence_timeout_seconds: 30,
      metadata: {
        trial_id: trial.id,
        industry: trial.industry,
        business_name: trial.business_name
      }
    }
  end
end
