class BusinessOwnership < ApplicationRecord
  belongs_to :user
  belongs_to :business

  validates :user_id, uniqueness: { scope: :business_id }
end
