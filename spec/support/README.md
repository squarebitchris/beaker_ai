# Test Support Documentation

This directory contains helper modules and configurations for the Beaker AI test suite.

## Available Helpers

### CircuitBreakerHelpers

Located in `spec/support/circuit_breaker_helpers.rb`

Provides utilities for testing circuit breaker behavior in API clients.

**Methods:**
- `reset_circuit_breakers` - Clears all circuit breaker state between tests
- `force_circuit_open(name)` - Forces a circuit breaker to open for testing
- `circuit_open?(name)` - Checks if a circuit breaker is open
- `circuit_closed?(name)` - Checks if a circuit breaker is closed
- `circuit_failures(name)` - Gets failure count for a circuit breaker
- `wait_for_circuit_reset(name, timeout_seconds)` - Advances time to test circuit reset

**Usage Example:**
```ruby
RSpec.describe VapiClient do
  it 'handles circuit breaker opening' do
    force_circuit_open('vapi:create_assistant')
    
    expect {
      client.create_assistant(config: {})
    }.to raise_error(ApiClientBase::CircuitOpenError)
    
    expect(circuit_open?('vapi:create_assistant')).to be true
  end
end
```

### JobHelpers

Located in `spec/support/job_helpers.rb`

Provides utilities for testing background jobs with ActiveJob.

**Features:**
- Automatically clears enqueued and performed jobs between tests
- Includes `ActiveJob::TestHelper` methods

**Usage Example:**
```ruby
RSpec.describe WebhookProcessorJob do
  it 'enqueues job successfully' do
    expect {
      WebhookProcessorJob.perform_later(webhook_event.id)
    }.to have_enqueued_job(WebhookProcessorJob)
  end
  
  it 'processes job correctly' do
    perform_enqueued_jobs do
      WebhookProcessorJob.perform_later(webhook_event.id)
    end
    
    expect(webhook_event.reload.status).to eq('completed')
  end
end
```

### FactoryBot

Located in `spec/support/factory_bot.rb`

Provides FactoryBot syntax methods in all specs.

**Available Factories:**
- `user` - User model with email validation
- `trial` - Trial model with traits for different states
- `call` - Call model with polymorphic associations
- `business` - Business model with Stripe integration
- `webhook_event` - Webhook event model for testing

**Factory Traits:**
```ruby
# Trial traits
create(:trial, :active)           # Active trial with Vapi assistant
create(:trial, :expired)          # Expired trial
create(:trial, :with_calls)       # Trial with associated calls

# Call traits
create(:call, :completed)         # Completed call with duration
create(:call, :with_transcript)   # Call with transcript and lead data

# Business traits
create(:business, :pro_plan)      # Pro plan business
create(:business, :with_owner)    # Business with owner user
```

### Shoulda Matchers

Located in `spec/support/shoulda_matchers.rb`

Provides Rails-specific matchers for testing models.

**Common Matchers:**
```ruby
# Model validations
it { should validate_presence_of(:email) }
it { should validate_uniqueness_of(:email).case_insensitive }
it { should validate_numericality_of(:calls_used) }

# Model associations
it { should belong_to(:user) }
it { should have_many(:calls) }
it { should have_one(:phone_number) }

# Model enums
it { should define_enum_for(:status) }
it { should define_enum_for(:direction) }
```

### VCR (Video Cassette Recorder)

Located in `spec/support/vcr.rb`

Records and replays HTTP interactions for consistent API testing.

**Usage:**
```ruby
RSpec.describe VapiClient do
  it 'creates assistant', :vcr do
    # This will record the HTTP request/response
    result = client.create_assistant(config: { name: 'Test' })
    expect(result['id']).to be_present
  end
end
```

**Configuration:**
- Cassettes stored in `spec/vcr_cassettes/`
- Sensitive data filtered (API keys, tokens)
- Re-records every 90 days
- Ignores localhost connections

### DatabaseCleaner

Located in `spec/support/database_cleaner.rb`

Ensures clean database state between tests.

**Strategy:**
- Uses transactions for most tests (fast)
- Uses truncation for feature/system tests (thorough)
- Cleans database before test suite runs

## Testing Best Practices

### Model Specs
```ruby
RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
  end
  
  describe 'associations' do
    it { should have_many(:trials) }
  end
  
  describe 'callbacks' do
    it 'normalizes email on save' do
      user = create(:user, email: '  User@Example.COM  ')
      expect(user.email).to eq('user@example.com')
    end
  end
end
```

### Service Specs
```ruby
RSpec.describe VapiClient do
  let(:client) { described_class.new }
  
  describe '#create_assistant' do
    context 'when API succeeds' do
      it 'returns assistant data' do
        stub_request(:post, 'https://api.vapi.ai/assistant')
          .to_return(status: 200, body: { id: 'asst_123' }.to_json)
        
        result = client.create_assistant(config: {})
        expect(result['id']).to eq('asst_123')
      end
    end
  end
end
```

### Request Specs
```ruby
RSpec.describe 'Magic Link Authentication', type: :request do
  describe 'POST /users/sign_in' do
    it 'sends magic link email' do
      expect {
        post user_session_path, params: { user: { email: 'test@example.com' } }
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
      
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
```

### Job Specs
```ruby
RSpec.describe WebhookProcessorJob, type: :job do
  describe '#perform' do
    it 'processes webhook event' do
      allow_any_instance_of(Webhooks::Stripe::CheckoutSessionProcessor)
        .to receive(:process)
      
      perform_enqueued_jobs do
        WebhookProcessorJob.perform_later(webhook_event.id)
      end
      
      expect(webhook_event.reload.status).to eq('completed')
    end
  end
end
```

## Running Tests

### Individual Test Files
```bash
bundle exec rspec spec/models/user_spec.rb
bundle exec rspec spec/services/vapi_client_spec.rb
```

### Focused Tests
```ruby
# In your spec file
fit 'only this test runs' do
  # test code
end

# Or from command line
bundle exec rspec --tag focus
```

### Failed Tests Only
```bash
bundle exec rspec --only-failures
```

### Parallel Execution
```bash
bundle exec parallel_rspec spec/
```

### Coverage Report
```bash
bundle exec rspec
# Coverage report generated in coverage/index.html
```

## Environment Variables for Testing

Set these in your `.env.test` file:
```
DATABASE_URL=postgresql://localhost/beaker_ai_test
VAPI_API_KEY=test_key
STRIPE_SECRET_KEY=sk_test_...
TWILIO_AUTH_TOKEN=test_token
SENTRY_DSN=test_dsn
```
