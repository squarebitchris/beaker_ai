class PhoneNumber < ApplicationRecord
  belongs_to :business

  validates :e164, :twilio_sid, presence: true
  validates :e164, uniqueness: { case_sensitive: false }, format: { with: /\A\+1\d{10}\z/, message: "must be US E.164 format" }
  validates :twilio_sid, uniqueness: { case_sensitive: true }

  scope :active, -> { joins(:business).where(businesses: { status: :active }) }

  def formatted
    # Returns (XXX) XXX-XXXX
    digits = e164.gsub(/\D/, "")
    "(#{digits[1..3]}) #{digits[4..6]}-#{digits[7..10]}"
  end
end
