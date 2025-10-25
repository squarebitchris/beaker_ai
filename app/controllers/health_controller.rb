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
    # Check SolidQueue is configured (tables will be created by queue migrations)
    defined?(SolidQueue) ? true : false
  end
end
