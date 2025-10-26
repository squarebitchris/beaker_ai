Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1"),
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  }

  # Load recurring jobs from schedule.yml
  schedule_file = "config/schedule.yml"
  if File.exist?(schedule_file) && Sidekiq.server?
    schedule = YAML.load_file(schedule_file)
    environment_schedule = schedule[Rails.env] || {}

    environment_schedule.each do |name, job_spec|
      Sidekiq::Cron::Job.create(
        name: name,
        cron: job_spec["cron"],
        class: job_spec["class"],
        queue: job_spec["queue"] || "default"
      )
    end
  end
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1"),
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  }
end
