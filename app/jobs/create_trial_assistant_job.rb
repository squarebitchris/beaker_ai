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

    # Use PromptBuilder to merge template + persona
    prompt_data = PromptBuilder.call(
      template: template.prompt_pack,
      persona: persona,
      kb: {} # No KB for Phase 1
    )

    # Build Vapi assistant config
    {
      name: "#{trial.business_name} Assistant",
      model: {
        provider: "openai",
        model: "gpt-4o-mini",
        systemMessage: prompt_data[:system],
        messages: [
          {
            role: "assistant",
            content: prompt_data[:first_message]
          }
        ],
        tools: prompt_data[:tools]
      },
      voice: {
        provider: "elevenlabs",
        voiceId: "rachel" # Default voice
      },
      maxDurationSeconds: 120, # 2 minute limit for trials
      metadata: {
        trial_id: trial.id,
        industry: trial.industry,
        business_name: trial.business_name
      }
    }
  end
end
