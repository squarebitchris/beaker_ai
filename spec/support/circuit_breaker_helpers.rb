module CircuitBreakerHelpers
  # Reset all circuit breakers between tests
  def reset_circuit_breakers
    Rails.cache.clear
  end
  
  # Force a circuit breaker to open for testing
  def force_circuit_open(name)
    light = Stoplight(name)
    # Simulate failures by directly manipulating the data store
    data_store = Stoplight.default_data_store
    
    # Record enough failures to trigger circuit open
    5.times do
      data_store.record_failure(light, Time.current)
    end
  end
  
  # Check if a circuit breaker is open
  def circuit_open?(name)
    light = Stoplight(name)
    Stoplight.default_data_store.get_state(light) == Stoplight::Color::RED
  end
  
  # Check if a circuit breaker is closed
  def circuit_closed?(name)
    light = Stoplight(name)
    Stoplight.default_data_store.get_state(light) == Stoplight::Color::GREEN
  end
  
  # Get circuit breaker failure count
  def circuit_failures(name)
    light = Stoplight(name)
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
  
  # Reset circuit breakers before each test
  config.before(:each) do
    reset_circuit_breakers
  end
end
