# frozen_string_literal: true

module Webhooks
  module Stripe
    class CheckoutSessionProcessor
      def initialize(webhook_event)
        @event = webhook_event
        @payload = webhook_event.payload.with_indifferent_access
      end

      def process
        session_data = @payload.dig(:data, :object)
        return unless session_data

        metadata = session_data[:metadata]
        unless metadata && metadata[:user_id] && metadata[:trial_id]
          Rails.logger.warn("[Webhook] Missing metadata in checkout.session.completed")
          return
        end

        # Enqueue conversion job
        ConvertTrialToBusinessJob.perform_later(
          user_id: metadata[:user_id],
          trial_id: metadata[:trial_id],
          stripe_customer_id: session_data[:customer],
          stripe_subscription_id: session_data[:subscription],
          plan: metadata[:plan],
          business_name: metadata[:business_name]
        )

        Rails.logger.info("[Webhook] Enqueued ConvertTrialToBusinessJob for session #{session_data[:id]}")
        Rails.logger.info("[Webhook] Metadata: #{metadata.inspect}")
      end
    end
  end
end
