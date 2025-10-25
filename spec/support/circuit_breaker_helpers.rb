module CircuitBreakerHelpers
  # Reset all circuit breakers between tests
  def reset_circuit_breakers
    # For MemoryStore, we need to clear the entire cache
    Rails.cache.clear

    # Also try to clear specific stoplight keys if they exist
    begin
      Rails.cache.delete_matched("stoplight:*")
    rescue => e
      # Ignore if delete_matched is not supported
    end

    # Reset Stoplight data store
    Stoplight.default_data_store = Stoplight::DataStore::Memory.new
  end

  # Force a circuit breaker to open for testing
  def force_circuit_open(name)
    # Use the same configuration as ApiClientBase
    light = Stoplight(name)
      .with_threshold(5)      # Open after 5 failures
      .with_cool_off_time(60) # Try again after 60 seconds

    # Simulate failures by directly manipulating the data store
    data_store = Stoplight.default_data_store

    # Record enough failures to trigger circuit open
    5.times do
      data_store.record_failure(light, Time.current)
    end

    # Force state to red
    data_store.record_state(light, Stoplight::Color::RED)

    # Debug: Check if the state was actually set
    puts "After force_circuit_open:"
    puts "  Circuit breaker open? #{circuit_open?(name)}"
    puts "  Circuit breaker failures: #{circuit_failures(name)}"
    puts "  Data store state: #{data_store.get_state(light)}"
  end

  # Check if a circuit breaker is open
  def circuit_open?(name)
    light = Stoplight(name)
      .with_threshold(5)      # Open after 5 failures
      .with_cool_off_time(60) # Try again after 60 seconds
    Stoplight.default_data_store.get_state(light) == Stoplight::Color::RED
  end

  # Check if a circuit breaker is closed
  def circuit_closed?(name)
    light = Stoplight(name)
      .with_threshold(5)      # Open after 5 failures
      .with_cool_off_time(60) # Try again after 60 seconds
    Stoplight.default_data_store.get_state(light) == Stoplight::Color::GREEN
  end

  # Get circuit breaker failure count
  def circuit_failures(name)
    light = Stoplight(name)
      .with_threshold(5)      # Open after 5 failures
      .with_cool_off_time(60) # Try again after 60 seconds
    Stoplight.default_data_store.get_failures(light)
  end

  # Wait for circuit breaker to reset (for testing timeout behavior)
  def wait_for_circuit_reset(name, timeout_seconds = 60)
    light = Stoplight(name).with_timeout(timeout_seconds)

    # Advance time to trigger circuit reset
    travel timeout_seconds + 1.second
  end
end

RSpec.configure do |config|
  config.include CircuitBreakerHelpers
  config.include ActiveSupport::Testing::TimeHelpers
end
