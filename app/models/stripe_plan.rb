class StripePlan < ApplicationRecord
  validates :plan_name, presence: true, uniqueness: true
  validates :stripe_price_id, presence: true, uniqueness: true
  validates :base_price_cents, :calls_included, numericality: { greater_than: 0 }
  validates :overage_cents_per_call, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }

  def self.for_plan(plan_name)
    find_by(plan_name: plan_name.to_s, active: true)
  end

  def base_price_dollars
    base_price_cents / 100.0
  end
end
