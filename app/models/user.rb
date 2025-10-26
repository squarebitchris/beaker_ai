class User < ApplicationRecord
  devise :magic_link_authenticatable, :trackable

  has_many :trials, dependent: :destroy
  has_many :business_ownerships, dependent: :destroy
  has_many :businesses, through: :business_ownerships
  has_many :email_subscriptions, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  normalizes :email, with: ->(email) { email.strip.downcase }

  scope :admins, -> { where(admin: true) }
end
