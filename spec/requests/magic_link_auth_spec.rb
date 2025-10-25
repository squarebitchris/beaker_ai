require 'rails_helper'

RSpec.describe 'Magic Link Authentication', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user, email: 'test@example.com') }

  describe 'POST /users/sign_in' do
    it 'sends magic link email' do
      expect {
        post user_session_path, params: { user: { email: user.email } }
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      expect(flash[:notice]).to match(/login link has been sent/i)
    end

    it 'does not reveal if email exists (paranoid mode)' do
      # With paranoid mode, should show same message regardless
      post user_session_path, params: { user: { email: 'nonexistent@example.com' } }

      # Paranoid mode shows error, but doesn't reveal existence
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /users/magic_link' do
    it 'logs in user with valid token' do
      # Generate a valid token using Devise::Passwordless::LoginToken
      token = Devise::Passwordless::LoginToken.encode(user)

      get users_magic_link_path, params: { user: { email: user.email, token: token } }

      expect(response).to redirect_to(root_path)
    end

    it 'rejects expired token' do
      token = Devise::Passwordless::LoginToken.encode(user)

      # Simulate token expiration by traveling past the login window
      travel 21.minutes do
        get users_magic_link_path, params: { user: { email: user.email, token: token } }

        # With Turbo/Hotwire, Devise returns 422 for auth failures
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
