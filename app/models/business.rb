class Business < ApplicationRecord
  has_many :business_ownerships, dependent: :destroy
  has_many :owners, through: :business_ownerships, source: :user
  has_many :calls, as: :callable, dependent: :destroy
  # has_one :phone_number, dependent: :destroy  # TODO: Create PhoneNumber model in Phase 4
  
  enum :status, { active: 'active', past_due: 'past_due', canceled: 'canceled' }
  enum :plan, { starter: 'starter', pro: 'pro' }
  
  validates :name, :stripe_customer_id, :plan, presence: true
  validates :stripe_customer_id, uniqueness: true
  validates :calls_included, numericality: { greater_than: 0 }
  
  before_validation :set_calls_included, on: :create
  
  def calls_remaining
    calls_included - calls_used_this_period
  end
  
  def over_limit?
    calls_used_this_period >= calls_included
  end
  
  private
  
  def set_calls_included
    self.calls_included ||= case plan
    when 'starter' then 100
    when 'pro' then 500
    else 100
    end
  end
end
