# Temporarily disable VCR to fix WebMock issues
# require 'vcr'

# VCR.configure do |config|
#   config.cassette_library_dir = 'spec/vcr_cassettes'
#   config.hook_into :webmock
#   config.configure_rspec_metadata!
#   config.default_cassette_options = {
#     record: :once,
#     re_record_interval: 90.days
#   }

#   # Disable VCR for service tests
#   config.ignore_localhost = true
#   config.allow_http_connections_when_no_cassette = true

#   # Filter sensitive data
#   config.filter_sensitive_data('<VAPI_API_KEY>') { ENV['VAPI_API_KEY'] }
#   config.filter_sensitive_data('<STRIPE_SECRET_KEY>') { ENV['STRIPE_SECRET_KEY'] }
#   config.filter_sensitive_data('<TWILIO_AUTH_TOKEN>') { ENV['TWILIO_AUTH_TOKEN'] }
# end
