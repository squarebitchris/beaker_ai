# frozen_string_literal: true

module Webhooks
  module Stripe
    class SubscriptionProcessor
      def initialize(webhook_event)
        @event = webhook_event
        @payload = webhook_event.payload.with_indifferent_access
      end

      def process
        event_type = @payload[:type]
        Rails.logger.info("[Webhook] Stripe subscription event: #{event_type} - processor not yet implemented")
      end
    end
  end
end
