class User < ApplicationRecord
  devise :magic_link_authenticatable, :trackable

  has_many :trials, dependent: :destroy
  has_many :business_ownerships, dependent: :destroy
  has_many :businesses, through: :business_ownerships
  has_many :email_subscriptions, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  # Normalize email to prevent abuse via + aliases (user+test@example.com -> user@example.com)
  normalizes :email, with: ->(email) do
    email.strip.downcase.gsub(/\+.*@/, "@")
  end

  # Prevent excessive trial creation
  validate :trial_creation_limit, on: :create, if: -> { trials.loaded? }

  scope :admins, -> { where(admin: true) }

  def admin?
    admin
  end

  # Check if user can create a new trial (rate limiting)
  def can_create_trial?
    # Max 2 trials per 24 hours
    trials.where("created_at > ?", 24.hours.ago).count < 2
  end

  # Find potential abusers for monitoring
  def self.potential_abusers(days: 7)
    select("users.*, COUNT(trials.id) as trial_count")
      .joins(:trials)
      .where("trials.created_at > ?", days.days.ago)
      .group("users.id")
      .having("COUNT(trials.id) > 3")
      .order("trial_count DESC")
  end

  private

  def trial_creation_limit
    if trials.size > 5
      errors.add(:trials, "Maximum 5 trials per account")
    end
  end
end
