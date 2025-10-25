class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_signature
  before_action :cache_request_body

  def create
    event = WebhookEvent.find_or_create_by(
      provider: params[:provider],
      event_id: webhook_event_id
    ) do |new_event|
      new_event.event_type = webhook_event_type
      new_event.payload = webhook_payload
    end

    if event.previously_new_record?
      WebhookProcessorJob.perform_later(event.id)
      Rails.logger.info("[Webhook] New #{params[:provider]} event: #{event.event_type} (#{event.event_id})")
    else
      Rails.logger.info("[Webhook] Duplicate #{params[:provider]} event: #{event.event_type} (#{event.event_id})")
    end

    head :ok
  rescue => e
    Sentry.capture_exception(e, extra: { provider: params[:provider], payload: @cached_body })
    head :internal_server_error
  end

  private

  def cache_request_body
    @cached_body = request.body.read || request.raw_post || ""
    request.body.rewind
    @cached_body = @cached_body.to_s # Ensure it's always a string
  end

  def verify_signature
    case params[:provider]
    when "stripe"
      verify_stripe_signature
    when "twilio"
      verify_twilio_signature
    when "vapi"
      verify_vapi_signature
    else
      head :not_found
    end
  end

  def verify_stripe_signature
    sig_header = request.headers["Stripe-Signature"]

    begin
      Stripe::Webhook.construct_event(
        @cached_body,
        sig_header,
        ENV.fetch("STRIPE_WEBHOOK_SECRET", "test_secret")
      )
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error("[Webhook] Stripe signature verification failed: #{e.message}")
      Sentry.capture_message("Stripe webhook signature failed", level: :warning)
      head :unauthorized
    end
  end

  def verify_twilio_signature
    signature = request.headers["X-Twilio-Signature"]
    url = request.original_url

    validator = Twilio::Security::RequestValidator.new(ENV.fetch("TWILIO_AUTH_TOKEN", "test_token"))

    unless validator.validate(url, request.POST, signature)
      Rails.logger.error("[Webhook] Twilio signature verification failed")
      Sentry.capture_message("Twilio webhook signature failed", level: :warning)
      head :unauthorized
    end
  end

  def verify_vapi_signature
    signature = request.headers["x-vapi-signature"]
    secret = ENV.fetch("VAPI_WEBHOOK_SECRET", "test_secret")

    expected_signature = OpenSSL::HMAC.hexdigest("SHA256", secret, @cached_body)

    unless Rack::Utils.secure_compare(expected_signature, signature)
      Rails.logger.error("[Webhook] Vapi signature verification failed")
      Sentry.capture_message("Vapi webhook signature failed", level: :warning)
      head :unauthorized
    end
  end

  def webhook_event_id
    case params[:provider]
    when "stripe"
      parsed_body["id"]
    when "twilio"
      params["CallSid"] || params["MessageSid"]
    when "vapi"
      parsed_body.dig("message", "id")
    end
  end

  def webhook_event_type
    case params[:provider]
    when "stripe"
      parsed_body["type"]
    when "twilio"
      params["CallStatus"] ? "call_status" : "message_status"
    when "vapi"
      parsed_body.dig("message", "type")
    end
  end

  def webhook_payload
    parsed_body
  end

  def parsed_body
    @parsed_body ||= begin
      if @cached_body.present?
        JSON.parse(@cached_body)
      else
        # Handle case where params contains JSON string
        post_data = request.POST.to_h
        if post_data.values.first.is_a?(String) && post_data.values.first.start_with?("{")
          JSON.parse(post_data.values.first)
        else
          post_data
        end
      end
    rescue JSON::ParserError
      request.POST.to_h
    end
  end
end
