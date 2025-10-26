class EmailSubscription < ApplicationRecord
  belongs_to :user, optional: true

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :marketing_consent, inclusion: { in: [ true, false ] }
  validates :source, presence: true
  validates :subscribed_at, presence: true

  scope :opted_in, -> { where(marketing_consent: true) }
  scope :by_source, ->(source) { where(source: source) }

  before_validation :normalize_email, :set_defaults

  private

  def normalize_email
    self.email = email.strip.downcase if email.present?
  end

  def set_defaults
    self.subscribed_at ||= Time.current
  end
end
