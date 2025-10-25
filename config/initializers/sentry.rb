Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]

  # Set traces_sample_rate to 1.0 to capture 100% of transactions for performance monitoring.
  config.traces_sample_rate = ENV.fetch("SENTRY_TRACES_SAMPLE_RATE", 0.1).to_f

  config.enabled_environments = %w[production staging]

  # Filter sensitive data from webhooks and other sources
  config.before_send = lambda do |event, hint|
    # Remove sensitive webhook payload data
    if event.extra&.dig(:webhook_payload)
      event.extra[:webhook_payload] = "[FILTERED]"
    end

    # Remove sensitive request data
    if event.request&.dig(:data)
      event.request[:data] = "[FILTERED]"
    end

    # Remove sensitive headers
    if event.request&.dig(:headers)
      sensitive_headers = %w[authorization x-api-key stripe-signature x-twilio-signature x-vapi-signature]
      sensitive_headers.each do |header|
        event.request[:headers][header] = "[FILTERED]" if event.request[:headers][header]
      end
    end

    # Add custom tags to each event
    event.tags ||= {}
    event.tags[:environment] = Rails.env
    event.tags[:app] = "beaker_ai"

    event
  end

  # Configure release tracking (optional - can be set via ENV)
  if ENV["SENTRY_RELEASE"]
    config.release = ENV["SENTRY_RELEASE"]
  end
end
