class Trial < ApplicationRecord
  belongs_to :user
  belongs_to :scenario_template, optional: true
  has_many :calls, as: :callable, dependent: :destroy

  enum :status, { pending: "pending", active: "active", converted: "converted", expired: "expired" }
  enum :industry, { hvac: "hvac", gym: "gym", dental: "dental" }

  validates :business_name, :scenario, :phone_e164, presence: true
  validates :calls_used, numericality: { greater_than_or_equal_to: 0 }
  validate :calls_used_within_limit

  # Prevent duplicate trials for same phone within 48 hours (abuse prevention)
  validates :phone_e164, uniqueness: {
    scope: :user_id,
    conditions: -> { where("created_at > ?", 48.hours.ago) },
    message: "You recently created a trial for this number. Please wait 48 hours."
  }

  # Normalize phone number to E.164 format
  normalizes :phone_e164, with: ->(phone) do
    next phone if phone.blank?

    # Remove all non-digits
    digits = phone.to_s.gsub(/\D/, "")

    # Add +1 prefix if not present (US only for MVP)
    digits = "1#{digits}" unless digits.start_with?("1")

    # Return E.164 format
    "+#{digits}"
  end

  scope :active, -> { where(status: "active").where("expires_at > ?", Time.current) }
  scope :expired_pending, -> { where(status: "pending").where("expires_at < ?", Time.current) }
  scope :ready, -> { where.not(vapi_assistant_id: nil) }

  before_validation :set_expires_at, on: :create

  def calls_remaining
    calls_limit - calls_used
  end

  def expired?
    expires_at < Time.current
  end

  def ready?
    vapi_assistant_id.present? && status == "active"
  end

  private

  def set_expires_at
    self.expires_at ||= 48.hours.from_now
  end

  def calls_used_within_limit
    if calls_used > calls_limit
      errors.add(:calls_used, "cannot exceed limit of #{calls_limit}")
    end
  end
end
