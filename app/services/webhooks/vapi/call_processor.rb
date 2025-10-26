# frozen_string_literal: true

module Webhooks
  module Vapi
    class CallProcessor
      def initialize(webhook_event)
        @event = webhook_event
        @payload = webhook_event.payload.with_indifferent_access
      end

      def process
        start_time = Time.current

        return unless @payload[:type] == "call.ended"

        call_data = @payload[:call]
        return unless call_data

        vapi_call_id = call_data[:id]
        return unless vapi_call_id

        # NEW: Find business first, fall back to trial
        business = find_business_from_assistant
        trial = find_trial_from_assistant if business.nil?

        unless business || trial
          assistant_id = @payload.dig(:assistant, :id)
          Rails.logger.warn("[Webhook] No business or trial found for assistant_id: #{assistant_id}")
          return
        end

        callable = business || trial
        direction = business ? :inbound : :outbound_trial

        # Find or create call record
        call = Call.find_or_initialize_by(vapi_call_id: vapi_call_id)

        # Only create and update if this is a new call
        if call.new_record?
          phone = call_data[:to] || extract_phone(callable)

          call.assign_attributes(
            callable: callable,
            direction: direction,
            to_e164: phone,
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

            # Increment correct counter based on type
            if business
              business.increment!(:calls_used_this_period)
              broadcast_to_business(call, business)
            else
              trial.increment!(:calls_used)
              broadcast_to_trial(call, trial)
            end

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

        # Log success
        callable_type = business ? "business" : "trial"
        Rails.logger.info("[Webhook] Created/updated Call #{call.id} from Vapi webhook #{vapi_call_id} for #{callable_type} #{callable.id}")
        if business
          Rails.logger.info("[Webhook] Business #{business.id} now has #{business.calls_used_this_period} calls used")
        else
          Rails.logger.info("[Webhook] Trial #{trial.id} now has #{trial.calls_used} calls used")
        end

        # Log latency for monitoring
        log_performance(start_time, call, callable)
      rescue StandardError => e
        Rails.logger.error("[Webhook] Error processing Vapi call webhook: #{e.message}")
        Sentry.capture_exception(e, extra: { webhook_event_id: @event.id, vapi_call_id: vapi_call_id })
        raise
      end

      private

      def find_business_from_assistant
        assistant_id = @payload.dig(:assistant, :id)
        return nil unless assistant_id

        Business.find_by(vapi_assistant_id: assistant_id)
      end

      def find_trial_from_assistant
        assistant_id = @payload.dig(:assistant, :id)
        return nil unless assistant_id

        Trial.find_by(vapi_assistant_id: assistant_id)
      end

      def extract_phone(callable)
        if callable.respond_to?(:phone_e164)
          callable.phone_e164
        elsif callable.respond_to?(:phone_number) && callable.phone_number.present?
          callable.phone_number.e164
        else
          nil
        end
      end

      def broadcast_to_business(call, business)
        # Generate call card HTML
        call_html = ApplicationController.render(
          partial: "businesses/call",
          locals: { call: call }
        )

        # Generate stats HTML
        stats_html = ApplicationController.render(
          partial: "businesses/stats",
          locals: { business: business.reload }
        )

        # Create Turbo Stream tags for prepend and replace
        prepend_stream = %(<turbo-stream action="prepend" target="business_calls">#{call_html}</turbo-stream>)
        replace_stream = %(<turbo-stream action="replace" target="business_stats">#{stats_html}</turbo-stream>)

        # Broadcast both updates via ActionCable
        ActionCable.server.broadcast(
          "business:#{business.id}",
          prepend_stream + replace_stream
        )

        Rails.logger.info("[Webhook] Broadcasted call #{call.id} to BusinessChannel for business #{business.id}")
      end

      def broadcast_to_trial(call, trial)
        # Generate Turbo Stream HTML for prepending the call card
        call_html = ApplicationController.render(
          partial: "trials/call",
          locals: { call: call }
        )

        stats_html = ApplicationController.render(
          partial: "trials/stats",
          locals: { trial: trial.reload }
        )

        # Create Turbo Stream tags for prepend and replace
        prepend_stream = %(<turbo-stream action="prepend" target="trial_calls">#{call_html}</turbo-stream>)
        replace_stream = %(<turbo-stream action="replace" target="trial_stats">#{stats_html}</turbo-stream>)

        # Broadcast both updates via ActionCable
        ActionCable.server.broadcast(
          "trial:#{trial.id}",
          prepend_stream + replace_stream
        )

        Rails.logger.info("[Webhook] Broadcasted call #{call.id} to TrialChannel for trial #{trial.id}")
      end

      def log_performance(start_time, call, callable)
        latency = Time.current - start_time
        callable_type = callable.class.name.downcase
        callable_id = callable.id

        Rails.logger.info(
          "[Performance] Webhook→CallCard latency: #{(latency * 1000).round(2)}ms " \
          "(call_id: #{call.id}, #{callable_type}_id: #{callable_id})"
        )

        # Alert if latency exceeds 3s SLO
        if latency > 3.seconds
          Sentry.capture_message(
            "Webhook processing exceeded 3s SLO",
            level: :warning,
            extra: {
              latency_ms: (latency * 1000).round(2),
              call_id: call.id,
              callable_type: callable_type,
              callable_id: callable_id
            }
          )
        end
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
