class WebhookProcessorJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform(webhook_event_id)
    event = WebhookEvent.find(webhook_event_id)

    return if event.completed?

    event.mark_processing!

    # Route to specific processor (to be implemented in future tickets)
    processor = case event.provider
    when "stripe"
      if event.event_type.match?(/checkout\.session\.completed/)
        # Webhooks::Stripe::CheckoutSessionProcessor.new(event) - Phase 3
        Rails.logger.info("[Webhook] Stripe checkout.session.completed - processor not yet implemented")
        nil
      else
        Rails.logger.warn("[Webhook] No processor for #{event.provider}:#{event.event_type}")
        nil
      end
    when "twilio"
      if event.event_type == "call_status"
        # Webhooks::Twilio::CallStatusProcessor.new(event) - Phase 4
        Rails.logger.info("[Webhook] Twilio call_status - processor not yet implemented")
        nil
      else
        Rails.logger.warn("[Webhook] No processor for #{event.provider}:#{event.event_type}")
        nil
      end
    when "vapi"
      if event.event_type.match?(/call\./)
        Webhooks::Vapi::CallProcessor.new(event)
      else
        Rails.logger.warn("[Webhook] No processor for #{event.provider}:#{event.event_type}")
        nil
      end
    else
      Rails.logger.warn("[Webhook] No processor for #{event.provider}:#{event.event_type}")
      nil
    end

    # Call process if processor exists and implements it
    processor.process if processor&.respond_to?(:process)

    event.mark_completed!

    Rails.logger.info("[Webhook] Processed #{event.provider}:#{event.event_type} (#{event.event_id})")
  rescue => e
    event.mark_failed!(e)
    Sentry.capture_exception(e, extra: { webhook_event_id: webhook_event_id, event: event.attributes })
    raise
  end
end
