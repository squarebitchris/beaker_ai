class Call < ApplicationRecord
  belongs_to :callable, polymorphic: true

  enum :direction, { inbound: "inbound", outbound_trial: "outbound_trial", outbound_lead: "outbound_lead" }
  enum :status, { initiated: "initiated", ringing: "ringing", in_progress: "in_progress", completed: "completed", failed: "failed" }
  enum :intent, { lead_intake: "lead_intake", scheduling: "scheduling", info: "info", other: "other" }, prefix: true

  validates :to_e164, presence: true
  validates :vapi_call_id, uniqueness: true, allow_nil: true
  validates :twilio_call_sid, uniqueness: true, allow_nil: true

  scope :completed, -> { where(status: "completed") }
  scope :today, -> { where("created_at >= ?", Time.current.beginning_of_day) }
  scope :for_business, ->(business_id) { where(callable_type: "Business", callable_id: business_id) }

  def total_cost
    (vapi_cost || 0) + (twilio_cost || 0) + (openai_cost || 0)
  end

  def duration_minutes
    return nil unless duration_seconds
    (duration_seconds / 60.0).round(1)
  end
end
