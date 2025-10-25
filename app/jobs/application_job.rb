class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  retry_on ActiveRecord::Deadlocked, wait: 5.seconds, attempts: 3

  # Retry transient errors with exponential backoff
  retry_on Net::OpenTimeout, Net::ReadTimeout, wait: :exponentially_longer, attempts: 3

  # Most jobs are safe to ignore if the underlying records are no longer available
  discard_on ActiveJob::DeserializationError

  # Log job lifecycle
  before_perform do |job|
    Rails.logger.info("[Job] Starting #{job.class.name} with args: #{job.arguments.inspect}")
  end

  after_perform do |job|
    Rails.logger.info("[Job] Completed #{job.class.name}")
  end
end
