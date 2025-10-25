class TestJob < ApplicationJob
  queue_as :default

  def perform(message)
    Rails.logger.info "TestJob executing: #{message}"
    sleep 2 # Simulate work
    Rails.logger.info "TestJob completed: #{message}"
    message
  end
end
