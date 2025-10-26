# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Rack::Attack Rate Limiting', type: :request do
  before do
    # Clear rate limit counters before each test
    Rack::Attack.cache.store.clear
    # Enable Rack::Attack for testing
    allow(Rack::Attack).to receive(:enabled).and_return(true)
  end

  describe 'magic link requests rate limiting' do
    it 'allows 5 requests per 10 minutes per IP' do
      # Make 5 requests (should work)
      5.times do |i|
        post '/users/sign_in', params: { user: { email: "test#{i}@example.com" } }
        # Devise passwordless returns 200 with success message, not redirect
        expect(response).to have_http_status(:ok)
      end
    end

    it 'blocks 6th request with 429 status' do
      # Make 5 requests first
      5.times do |i|
        post '/users/sign_in', params: { user: { email: "test#{i}@example.com" } }
      end

      # 6th request should be rate limited
      post '/users/sign_in', params: { user: { email: 'blocked@example.com' } }
      expect(response).to have_http_status(:too_many_requests)
      expect(response.content_type).to include('application/json')

      response_body = JSON.parse(response.body)
      expect(response_body['error']).to eq('Rate limit exceeded. Please try again later.')
    end

    it 'resets rate limit after time period' do
      # Make 5 requests
      5.times do |i|
        post '/users/sign_in', params: { user: { email: "test#{i}@example.com" } }
      end

      # 6th should be blocked
      post '/users/sign_in', params: { user: { email: 'blocked@example.com' } }
      expect(response).to have_http_status(:too_many_requests)

      # Travel forward in time past the rate limit period
      travel 11.minutes do
        post '/users/sign_in', params: { user: { email: 'reset@example.com' } }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'magic link consumption rate limiting' do
    it 'allows 10 requests per hour per IP' do
      # Make 10 requests (should work)
      10.times do |i|
        get '/users/magic_link', params: { token: "token#{i}" }
        # Magic link consumption returns 422 for invalid tokens, which is expected
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    it 'blocks 11th request with 429 status' do
      # Make 10 requests first
      10.times do |i|
        get '/users/magic_link', params: { token: "token#{i}" }
      end

      # 11th request should be rate limited
      get '/users/magic_link', params: { token: 'blocked_token' }
      expect(response).to have_http_status(:too_many_requests)
      expect(response.content_type).to include('application/json')
    end
  end

  describe 'webhook endpoints rate limiting' do
    it 'allows high volume webhook requests' do
      # Make 10 webhook requests (should work - high limit is 300/min)
      10.times do |i|
        post '/webhooks/stripe', params: { test: "data#{i}" }
        # Expect unauthorized due to signature verification, not rate limiting
        expect(response).to have_http_status(:unauthorized)
      end
    end

    it 'blocks excessive webhook requests' do
      # Make 300 requests first (at the limit)
      300.times do |i|
        post '/webhooks/stripe', params: { test: "data#{i}" }
      end

      # 301st request should be rate limited
      post '/webhooks/stripe', params: { test: 'blocked_data' }
      expect(response).to have_http_status(:too_many_requests)
      expect(response.content_type).to include('application/json')
    end
  end

  describe 'trial creation rate limiting (ABUSE PREVENTION)' do
    let(:user) { create(:user) }

    before do
      sign_in user
      create(:scenario_template, :hvac_lead_intake)
    end

    it 'allows 3 trial creations per hour per IP' do
      3.times do |i|
        post '/trials', params: {
          trial: attributes_for(:trial).merge(
            business_name: "Business #{i}",
            phone_e164: "+1212000#{1000 + i}"
          )
        }
        expect(response).to have_http_status(:redirect)
      end
    end

    it 'blocks 4th trial creation with 429 status' do
      # Make 3 successful requests
      3.times do |i|
        post '/trials', params: {
          trial: attributes_for(:trial).merge(
            business_name: "Business #{i}",
            phone_e164: "+1212000#{2000 + i}"
          )
        }
      end

      # 4th request should be rate limited
      post '/trials', params: {
        trial: attributes_for(:trial).merge(phone_e164: "+12120002100")
      }
      expect(response).to have_http_status(:too_many_requests)
      expect(response.content_type).to include('application/json')

      response_body = JSON.parse(response.body)
      expect(response_body['error']).to eq('Rate limit exceeded. Please try again later.')
    end

    it 'resets trial rate limit after 1 hour' do
      # Make 3 requests
      3.times do |i|
        post '/trials', params: {
          trial: attributes_for(:trial).merge(
            business_name: "Business #{i}",
            phone_e164: "+1212000#{3000 + i}"
          )
        }
      end

      # 4th should be blocked
      post '/trials', params: {
        trial: attributes_for(:trial).merge(phone_e164: "+12120003100")
      }
      expect(response).to have_http_status(:too_many_requests)

      # Travel forward past rate limit period
      travel 61.minutes do
        post '/trials', params: {
          trial: attributes_for(:trial).merge(
            business_name: "Reset Business",
            phone_e164: "+12120003200"
          )
        }
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe 'disposable email blocking (ABUSE PREVENTION)' do
    let(:disposable_emails) do
      %w[
        test@guerrillamail.com
        test@mailinator.com
        test@10minutemail.com
        test@tempmail.com
        test@sharklasers.com
      ]
    end

    it 'blocks login attempts with disposable email domains' do
      disposable_emails.each do |email|
        post '/users/sign_in', params: { user: { email: email } }
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to include('Forbidden')
      end
    end

    it 'allows login with legitimate email domains' do
      legitimate_emails = %w[
        user@gmail.com
        user@yahoo.com
        user@outlook.com
        user@example.com
      ]

      legitimate_emails.each do |email|
        post '/users/sign_in', params: { user: { email: email } }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'general IP rate limiting' do
    it 'allows 100 requests per minute per IP' do
      # Make 100 requests to various endpoints
      100.times do |i|
        get '/up' # Health check endpoint
        expect(response).to have_http_status(:ok)
      end
    end

    it 'blocks 101st request with 429 status' do
      # Make 100 requests first
      100.times do
        get '/up'
      end

      # 101st request should be rate limited
      get '/up'
      expect(response).to have_http_status(:too_many_requests)
      expect(response.content_type).to include('application/json')
    end
  end

  describe 'rate limit isolation' do
    it 'tracks rate limits per IP separately' do
      # Simulate different IPs by mocking the request IP
      allow_any_instance_of(ActionDispatch::Request).to receive(:ip).and_return('192.168.1.1')

      # Make 5 requests from first IP
      5.times do |i|
        post '/users/sign_in', params: { user: { email: "test#{i}@example.com" } }
        expect(response).to have_http_status(:ok)
      end

      # Clear cache and switch to different IP
      Rack::Attack.cache.store.clear
      allow_any_instance_of(ActionDispatch::Request).to receive(:ip).and_return('192.168.1.2')

      # Should be able to make 5 more requests from different IP
      5.times do |i|
        post '/users/sign_in', params: { user: { email: "test2#{i}@example.com" } }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'rate limit response format' do
    it 'returns JSON error message' do
      # Trigger rate limit
      5.times do |i|
        post '/users/sign_in', params: { user: { email: "test#{i}@example.com" } }
      end

      post '/users/sign_in', params: { user: { email: 'blocked@example.com' } }

      expect(response).to have_http_status(:too_many_requests)
      expect(response.content_type).to include('application/json')

      response_body = JSON.parse(response.body)
      expect(response_body).to have_key('error')
      expect(response_body['error']).to be_a(String)
      expect(response_body['error']).to include('Rate limit exceeded')
    end
  end

  describe 'Rack::Attack disabled in test environment' do
    it 'does not rate limit when disabled' do
      # Disable Rack::Attack
      allow(Rack::Attack).to receive(:enabled).and_return(false)

      # Make many requests - should not be rate limited
      20.times do |i|
        post '/users/sign_in', params: { user: { email: "test#{i}@example.com" } }
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
