class StartTrialCallJob < ApplicationJob
  queue_as :default

  retry_on ApiClientBase::CircuitOpenError, wait: :exponentially_longer, attempts: 3
  retry_on Net::OpenTimeout, Net::ReadTimeout, wait: :exponentially_longer, attempts: 3

  def perform(trial_id, phone_number)
    trial = Trial.find(trial_id)

    # Use with_lock to prevent race conditions (double-dial prevention)
    trial.with_lock do
      # Validate trial state
      unless trial.active?
        Rails.logger.warn("[StartTrialCallJob] Trial #{trial_id} not active: status=#{trial.status}")
        return
      end

      if trial.expired?
        Rails.logger.warn("[StartTrialCallJob] Trial #{trial_id} expired at #{trial.expires_at}")
        return
      end

      # Check trial limits
      if trial.calls_used >= trial.calls_limit
        Rails.logger.warn("[StartTrialCallJob] Trial #{trial_id} call limit reached: #{trial.calls_used}/#{trial.calls_limit}")
        return
      end

      # Check assistant is ready
      unless trial.vapi_assistant_id.present?
        Rails.logger.error("[StartTrialCallJob] Trial #{trial_id} has no vapi_assistant_id")
        return
      end

      # Enforce quiet hours (Phase 1 temporary)
      unless QuietHours.allow?(phone_number)
        Rails.logger.info("[StartTrialCallJob] Call blocked by quiet hours for #{phone_number}")
        return
      end

      # Create call record BEFORE API call (for observability)
      call = trial.calls.create!(
        direction: "outbound_trial",
        to_e164: phone_number,
        status: "initiated",
        started_at: Time.current
      )

      begin
        # Initiate Vapi call
        vapi_response = VapiClient.new.start_call(
          assistant_id: trial.vapi_assistant_id,
          phone_number: phone_number
        )

        # Update call with Vapi ID and status
        call.update!(
          vapi_call_id: vapi_response["id"],
          status: "ringing"
        )

        # Increment trial usage atomically
        trial.increment!(:calls_used)

        Rails.logger.info("[StartTrialCallJob] Call initiated for trial #{trial_id}: vapi_call_id=#{vapi_response['id']}")
      rescue => e
        # Update call status to failed but keep the record
        call.update!(status: "failed")
        Rails.logger.error("[StartTrialCallJob] Vapi call failed for trial #{trial_id}: #{e.message}")
        raise # Re-raise to trigger retry logic
      end
    end

  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error("[StartTrialCallJob] Trial #{trial_id} not found: #{e.message}")
    Sentry.capture_exception(e, extra: { trial_id: trial_id, phone_number: phone_number })
    # Don't retry - trial doesn't exist
  rescue => e
    Rails.logger.error("[StartTrialCallJob] Failed for trial #{trial_id}: #{e.message}")
    Sentry.capture_exception(e, extra: { trial_id: trial_id, phone_number: phone_number })
    raise # Let ActiveJob retry handle it
  end
end
