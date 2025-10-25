Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]

  # Set traces_sample_rate to 1.0 to capture 100% of transactions for performance monitoring.
  config.traces_sample_rate = ENV.fetch("SENTRY_TRACES_SAMPLE_RATE", 0.1).to_f

  config.enabled_environments = %w[production staging]

  # Filter sensitive data
  config.before_send = lambda do |event, hint|
    # Remove sensitive webhook payload data if needed
    event
  end
end
