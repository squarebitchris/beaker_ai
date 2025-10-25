class User < ApplicationRecord
  devise :magic_link_authenticatable, :trackable
  
  validates :email, presence: true, uniqueness: true
  normalizes :email, with: -> email { email.strip.downcase }
end
