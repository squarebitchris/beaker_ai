class HealthController < ApplicationController
  def up
    render json: {
      status: "ok",
      db: db_ok?,
      queue: queue_ok?
    }
  end

  private

  def db_ok?
    ActiveRecord::Base.connection.active?
  rescue
    false
  end

  def queue_ok?
    # Check Sidekiq is configured and Redis is reachable
    Sidekiq.redis(&:ping) == "PONG"
  rescue
    false
  end
end
