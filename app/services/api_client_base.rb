class ApiClientBase
  class CircuitOpenError < StandardError; end
  class ApiError < StandardError; end

  def with_circuit_breaker(name:, fallback: nil, &block)
    light = Stoplight(name)
      .with_threshold(5)      # Open after 5 failures
      .with_cool_off_time(60) # Try again after 60 seconds

    if fallback
      light = light.with_fallback do |error|
        Rails.logger.error("[CircuitBreaker] #{name} is open: #{error.message}")
        fallback.call
      end
    end

    light.run(&block)
  rescue Stoplight::Error::RedLight => e
    raise CircuitOpenError, "#{name} circuit breaker is open: #{e.message}"
  end

  # Retry with exponential backoff for transient errors
  def with_retry(attempts: 3, base_delay: 1)
    attempt = 0
    begin
      yield
    rescue Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNREFUSED => e
      attempt += 1
      if attempt < attempts
        delay = base_delay * (2 ** (attempt - 1))  # 1s, 2s, 4s
        Rails.logger.warn("[Retry] Attempt #{attempt}/#{attempts} failed: #{e.message}. Retrying in #{delay}s...")
        sleep delay
        retry
      else
        raise ApiError, "Failed after #{attempts} attempts: #{e.message}"
      end
    end
  end
end
