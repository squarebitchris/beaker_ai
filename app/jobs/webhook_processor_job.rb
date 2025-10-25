class WebhookProcessorJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform(webhook_event_id)
    event = WebhookEvent.find(webhook_event_id)

    return if event.completed?

    event.mark_processing!

    # Route to specific processor (to be implemented in future tickets)
    processor = case [ event.provider, event.event_type ]
    when [ "stripe", /checkout\.session\.completed/ ]
      # Webhooks::Stripe::CheckoutSessionProcessor.new(event) - Phase 3
      Rails.logger.info("[Webhook] Stripe checkout.session.completed - processor not yet implemented")
      nil
    when [ "twilio", "call_status" ]
      # Webhooks::Twilio::CallStatusProcessor.new(event) - Phase 4
      Rails.logger.info("[Webhook] Twilio call_status - processor not yet implemented")
      nil
    when [ "vapi", /call\./ ]
      # Webhooks::Vapi::CallProcessor.new(event) - Phase 2
      Rails.logger.info("[Webhook] Vapi call event - processor not yet implemented")
      nil
    else
      Rails.logger.warn("[Webhook] No processor for #{event.provider}:#{event.event_type}")
      nil
    end

    processor&.process
    event.mark_completed!

    Rails.logger.info("[Webhook] Processed #{event.provider}:#{event.event_type} (#{event.event_id})")
  rescue => e
    event.mark_failed!(e)
    Sentry.capture_exception(e, extra: { webhook_event_id: webhook_event_id, event: event.attributes })
    raise
  end
end
