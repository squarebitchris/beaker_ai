class Business < ApplicationRecord
  belongs_to :trial, optional: true
  has_many :business_ownerships, dependent: :destroy
  has_many :owners, through: :business_ownerships, source: :user
  has_many :calls, as: :callable, dependent: :destroy
  has_one :phone_number, dependent: :destroy

  enum :status, { active: "active", past_due: "past_due", canceled: "canceled" }
  enum :plan, { starter: "starter", pro: "pro" }

  validates :name, :stripe_customer_id, :plan, presence: true
  validates :stripe_customer_id, uniqueness: true
  validates :stripe_subscription_id, uniqueness: true, allow_nil: true
  validates :calls_included, numericality: { greater_than: 0 }

  before_validation :set_calls_included, on: :create

  def calls_remaining
    calls_included - calls_used_this_period
  end

  def over_limit?
    calls_used_this_period >= calls_included
  end

  def stripe_price_id
    StripePlan.for_plan(plan)&.stripe_price_id
  end

  def has_phone_number?
    phone_number.present?
  end

  private

  def set_calls_included
    self.calls_included ||= StripePlan.for_plan(plan)&.calls_included || default_calls_for_plan
  end

  def default_calls_for_plan
    case plan
    when "starter" then 100
    when "pro" then 300  # Updated from 500 to protect margins
    else 100
    end
  end
end
