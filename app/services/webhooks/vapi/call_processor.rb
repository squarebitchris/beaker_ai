# frozen_string_literal: true

module Webhooks
  module Vapi
    class CallProcessor
      def initialize(webhook_event)
        @event = webhook_event
        @payload = webhook_event.payload.with_indifferent_access
      end

      def process
        return unless @payload[:type] == "call.ended"

        call_data = @payload[:call]
        return unless call_data

        vapi_call_id = call_data[:id]
        return unless vapi_call_id

        # Find the trial from assistant_id
        trial = find_trial_from_assistant
        unless trial
          Rails.logger.warn("[Webhook] No trial found for assistant_id: #{@payload.dig(:assistant, :id)}")
          return
        end

        # Find or create call record
        call = Call.find_or_initialize_by(vapi_call_id: vapi_call_id)

        # Only create and update if this is a new call
        if call.new_record?
          call.assign_attributes(
            callable: trial,
            direction: :outbound_trial,
            to_e164: call_data[:to] || trial.phone_e164,
            status: :completed,
            duration_seconds: call_data[:duration],
            recording_url: call_data[:recordingUrl],
            transcript: call_data[:transcript],
            started_at: parse_timestamp(call_data[:startedAt]),
            ended_at: parse_timestamp(call_data[:endedAt]),
            vapi_cost: call_data[:cost],
            extracted_lead: LeadExtractor.from_function_calls(call_data[:functionCalls]),
            intent: IntentClassifier.call(call_data)
          )

          begin
            call.save!
            # Only increment if save was successful (truly a new call)
            trial.increment!(:calls_used)
          rescue ActiveRecord::RecordNotUnique
            Rails.logger.info("[Webhook] Call #{vapi_call_id} already processed by another worker")
            # Another worker already processed this - don't increment
            # Fetch the existing call and continue
            call = Call.find_by(vapi_call_id: vapi_call_id)
            unless call
              Rails.logger.warn("[Webhook] Call #{vapi_call_id} not found after RecordNotUnique")
              return
            end
          end
        else
          # Call already existed, don't increment
          Rails.logger.info("[Webhook] Call #{vapi_call_id} already exists, skipping")
        end

        Rails.logger.info("[Webhook] Created/updated Call #{call.id} from Vapi webhook #{vapi_call_id} for trial #{trial.id}")
        Rails.logger.info("[Webhook] Trial #{trial.id} now has #{trial.calls_used} calls used")
      rescue StandardError => e
        Rails.logger.error("[Webhook] Error processing Vapi call webhook: #{e.message}")
        Sentry.capture_exception(e, extra: { webhook_event_id: @event.id, vapi_call_id: vapi_call_id })
        raise
      end

      private

      def find_trial_from_assistant
        assistant_id = @payload.dig(:assistant, :id)
        return nil unless assistant_id

        Trial.find_by(vapi_assistant_id: assistant_id)
      end

      def parse_timestamp(timestamp_string)
        return nil unless timestamp_string

        Time.parse(timestamp_string)
      rescue ArgumentError => e
        Rails.logger.warn("[Webhook] Invalid timestamp format: #{timestamp_string} - #{e.message}")
        nil
      end
    end
  end
end
