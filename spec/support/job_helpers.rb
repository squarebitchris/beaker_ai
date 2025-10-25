require 'rails_helper'

RSpec.configure do |config|
  config.include ActiveJob::TestHelper
  
  # Clear jobs between tests
  config.before(:each) do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
