require "stoplight"

# Configure Stoplight to use Rails.cache (SolidCache) as data store
# We need to create a custom data store adapter since Stoplight expects Redis
class SolidCacheDataStore < Stoplight::DataStore::Base
  def initialize(cache_store)
    @cache_store = cache_store
  end

  def names
    # Get all circuit breaker names from cache
    @cache_store.read("stoplight:names") || []
  end

  def get_all(light)
    key = "stoplight:#{light.name}"
    @cache_store.read(key) || {}
  end

  def get_failures(light)
    get_all(light)["failures"] || 0
  end

  def get_state(light)
    get_all(light)["state"] || Stoplight::Color::GREEN
  end

  def get_last_failure_time(light)
    get_all(light)["last_failure_time"]
  end

  def record_failure(light, failure_time)
    key = "stoplight:#{light.name}"
    data = get_all(light)
    data["failures"] = (data["failures"] || 0) + 1
    data["last_failure_time"] = failure_time
    @cache_store.write(key, data, expires_in: 1.hour)

    # Update names list
    names = @cache_store.read("stoplight:names") || []
    names << light.name unless names.include?(light.name)
    @cache_store.write("stoplight:names", names.uniq, expires_in: 1.hour)
  end

  def record_state(light, state)
    key = "stoplight:#{light.name}"
    data = get_all(light)
    data["state"] = state
    @cache_store.write(key, data, expires_in: 1.hour)
  end

  def clear_failures(light)
    key = "stoplight:#{light.name}"
    data = get_all(light)
    data["failures"] = 0
    @cache_store.write(key, data, expires_in: 1.hour)
  end
end

# Set up Stoplight with SolidCache
Stoplight.default_data_store = SolidCacheDataStore.new(Rails.cache)

# Configure notifications to use Rails logger (Sentry integration handled separately)
Stoplight.default_notifiers = [
  Stoplight::Notifier::Logger.new(Rails.logger)
]

Rails.logger.info("[Stoplight] Circuit breaker configured with SolidCache data store")
