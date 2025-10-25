class WebhookEvent < ApplicationRecord
  enum :status, { pending: "pending", processing: "processing", completed: "completed", failed: "failed" }
  enum :provider, { stripe: "stripe", twilio: "twilio", vapi: "vapi" }

  validates :event_id, :event_type, presence: true
  validates :event_id, uniqueness: { scope: :provider }

  scope :unprocessed, -> { where(status: [ "pending", "failed" ]).where("retries < ?", 3) }
  scope :recent, -> { where("created_at > ?", 7.days.ago) }

  def mark_processing!
    update!(status: "processing", processed_at: Time.current)
  end

  def mark_completed!
    update!(status: "completed")
  end

  def mark_failed!(error)
    update!(
      status: "failed",
      error_message: error.message,
      retries: retries + 1
    )
  end
end
