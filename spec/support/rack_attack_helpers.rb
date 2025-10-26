# frozen_string_literal: true

module RackAttackHelpers
  # Clear all Rack::Attack rate limit counters
  def reset_rack_attack_counters
    Rack::Attack.cache.store.clear
  end

  # Simulate rate limit by making multiple requests
  # @param path [String] The path to request
  # @param method [Symbol] HTTP method (:get, :post, etc.)
  # @param count [Integer] Number of requests to make
  # @param params [Hash] Parameters to send with requests
  def simulate_rate_limit(path:, method: :get, count:, params: {})
    count.times do |i|
      case method
      when :get
        get path, params: params.merge(index: i)
      when :post
        post path, params: params.merge(index: i)
      when :put
        put path, params: params.merge(index: i)
      when :delete
        delete path, params: params.merge(index: i)
      else
        raise ArgumentError, "Unsupported HTTP method: #{method}"
      end
    end
  end

  # Enable Rack::Attack for testing
  def enable_rack_attack!
    allow(Rack::Attack).to receive(:enabled).and_return(true)
  end

  # Disable Rack::Attack for testing
  def disable_rack_attack!
    allow(Rack::Attack).to receive(:enabled).and_return(false)
  end

  # Mock request IP for testing IP-based rate limiting
  def mock_request_ip(ip)
    allow_any_instance_of(ActionDispatch::Request).to receive(:ip).and_return(ip)
  end

  # Check if a specific rate limit key exists in Redis
  def rate_limit_key_exists?(key)
    Rack::Attack.cache.store.exist?(key)
  end

  # Get the current count for a rate limit key
  def rate_limit_count(key)
    Rack::Attack.cache.store.read(key) || 0
  end

  # Manually set a rate limit counter (for testing edge cases)
  def set_rate_limit_count(key, count)
    Rack::Attack.cache.store.write(key, count)
  end

  # Wait for rate limit to expire (useful for testing time-based limits)
  def wait_for_rate_limit_expiry(period)
    travel(period + 1.second)
  end
end

# Include helpers in RSpec
RSpec.configure do |config|
  config.include RackAttackHelpers, type: :request
  config.include RackAttackHelpers, type: :controller

  # Clear rate limit counters before each test
  config.before(:each, type: :request) do
    reset_rack_attack_counters
  end

  config.before(:each, type: :controller) do
    reset_rack_attack_counters
  end
end
