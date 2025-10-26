# frozen_string_literal: true

class Rack::Attack
  # Use Redis for distributed rate limiting state
  # Use Redis DB 2 (separate from SolidQueue on DB 0)
  Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
    url: ENV.fetch("REDIS_URL", "redis://localhost:6379/2")
  )

  # Allowlist for trusted IPs (can be configured later)
  # safelist('allow from trusted IPs') do |req|
  #   req.ip.in?(['54.187.174.169', '54.187.205.235']) # Stripe webhook IPs
  # end

  # Rate limit magic link requests (prevent email bombing)
  throttle("magic_link_requests", limit: 5, period: 10.minutes) do |req|
    if req.path == "/users/sign_in" && req.post?
      req.ip
    end
  end

  # Rate limit magic link consumption (prevent brute force)
  throttle("magic_link_consumption", limit: 10, period: 1.hour) do |req|
    if req.path == "/users/magic_link" && req.get?
      req.ip
    end
  end

  # Rate limit trial creation (CRITICAL: prevent abuse and cost overruns)
  throttle("trials/ip", limit: 3, period: 1.hour) do |req|
    if req.path == "/trials" && req.post?
      req.ip
    end
  end

  # Rate limit webhook endpoints (prevent abuse)
  # High limit since signature verification is primary defense
  throttle("webhooks", limit: 300, period: 1.minute) do |req|
    if req.path.start_with?("/webhooks/")
      req.ip
    end
  end

  # General IP rate limiting (catch-all)
  throttle("req/ip", limit: 100, period: 1.minute) do |req|
    req.ip
  end

  # Blocklist for known bad actors (manual intervention)
  blocklist("block bad IPs") do |req|
    # You can add IPs here manually or via admin interface
    # Rack::Attack::BlockList.add("bad_ips", "1.2.3.4")
    false # No automatic blocking for now
  end

  # Block disposable email domains (abuse prevention)
  blocklist("block disposable emails") do |req|
    if req.path == "/users/sign_in" && req.post?
      email = req.params.dig("user", "email")
      if email
        disposable_domains = %w[
          guerrillamail mailinator 10minutemail tempmail
          throwaway trashmail fakeinbox yopmail
          sharklasers maildrop getnada temp-mail
        ]
        email.match?(/\@(#{disposable_domains.join('|')})\./)
      else
        false
      end
    else
      false
    end
  end

  # Custom response for rate limited requests
  self.throttled_responder = lambda do |env|
    [
      429,
      { "Content-Type" => "application/json" },
      [ { error: "Rate limit exceeded. Please try again later." }.to_json ]
    ]
  end

  # Log rate limit events for monitoring
  ActiveSupport::Notifications.subscribe("rack.attack") do |name, start, finish, request_id, payload|
    req = payload[:request]
    Rails.logger.warn("[Rack::Attack] #{req.env['rack.attack.match_type']} #{req.ip} #{req.path}")
  end
end

# Enable Rack::Attack only in production and staging
# Disabled in development/test for faster testing
Rack::Attack.enabled = Rails.env.production? || Rails.env.staging?
