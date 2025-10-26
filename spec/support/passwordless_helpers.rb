# frozen_string_literal: true

require 'warden/test/helpers'

module PasswordlessTestHelpers
  # Sign in a user for request specs using passwordless authentication
  # Uses Warden::Test::Helpers directly to bypass magic link flow
  # Override Devise's sign_in to use Warden's login_as instead
  def sign_in_passwordless(user)
    login_as(user, scope: :user)
  end

  def sign_out_passwordless
    logout(:user)
  end
end

RSpec.configure do |config|
  config.include PasswordlessTestHelpers, type: :request
  config.include Warden::Test::Helpers, type: :request

  # Define sign_in to use Warden instead of Devise's method
  config.before(:each, type: :request) do
    # This will work for most request specs
    def sign_in(user)
      login_as(user, scope: :user)
    end
  end

  # Clean up Warden after each request spec
  config.after(:each, type: :request) do
    Warden.test_reset!
  end
end
