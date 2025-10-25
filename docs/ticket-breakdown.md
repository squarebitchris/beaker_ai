# BEAKER AI - DETAILED TICKET BREAKDOWN
**Generated:** October 25, 2025  
**For:** Mid-level engineers creating execution-ready tickets  
**Prerequisite:** Read start.md and BUILD-GUIDE.md first  
**Stack:** Rails 7.1+, PostgreSQL 15+, Redis 7+, Sidekiq

---

## HOW TO USE THIS DOCUMENT

### Purpose
This document provides **execution-ready detail** for every ticket in the backlog. Each ticket includes:
- **Context:** Why this ticket matters (product + technical)
- **Implementation Hints:** File paths, classes, patterns to use
- **Detailed Acceptance Criteria:** Gherkin Given/When/Then scenarios
- **TDD Approach:** Which specs to write first, what to test
- **Done Checklist:** Quality gates before marking complete
- **Gotchas:** Pitfalls specific to this ticket

### Ticket Template Reference
Every ticket follows the BUILD-GUIDE.md template:
```
## TICKET: [ID] - [Title]

**Epic:** [Epic Name]
**Points:** [2-5]
**Priority:** [P0/P1]
**Dependencies:** [Other ticket IDs]

### Context & Why It Matters
[Product + technical reasoning]

### Implementation Hints
- **Files to create/modify:** [Specific paths]
- **Key patterns:** [From BUILD-GUIDE.md Section 10]
- **ENV vars needed:** [If applicable]
- **Gems to install:** [If applicable]

### Detailed Acceptance Criteria
**GIVEN** [precondition]
**WHEN** [action]
**THEN** [expected outcome]
**AND** [additional assertions]

[Multiple scenarios if needed]

### TDD Approach
1. **Write these specs first:**
   - [spec/path/file_spec.rb with specific examples]
2. **Then implement:**
   - [Implementation order]
3. **Verify:**
   - [Manual testing steps]

### Done Checklist
- [ ] [Specific quality gate]
- [ ] [Test coverage requirement]
- [ ] [Performance requirement]
- [ ] [Accessibility requirement if UI]

### Gotchas & Pitfalls
- [Common mistakes to avoid]
- [Edge cases to handle]

### References
- start.md: [Section numbers]
- BUILD-GUIDE.md: [Section numbers]
```

---

# PHASE 0: RAILS FOUNDATION & INFRASTRUCTURE

---

## TICKET: R1-E01-T001 - Initialize Rails 7.1 app with PostgreSQL + Redis

**Epic:** E-001: Rails Foundation & Infrastructure  
**Points:** 2  
**Priority:** P0  
**Dependencies:** None

### Context & Why It Matters
First ticket establishes foundation for entire app. Using Rails 7.1+ for modern Hotwire features, PostgreSQL for UUID primary keys (better for distributed systems), and Redis for Sidekiq + ActionCable.

### Implementation Hints
- **Command:** `rails new beaker_ai --database=postgresql --css=tailwind --javascript=esbuild --skip-test`
- **Then add:** `gem 'rspec-rails'` to Gemfile and run `rails generate rspec:install`
- **Redis config:** Add to `config/cable.yml` and Sidekiq config
- **Database config:** Use `DATABASE_URL` env var for 12-factor compliance

```ruby
# config/database.yml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  url: <%= ENV['DATABASE_URL'] %>

development:
  <<: *default
  database: beaker_ai_development

test:
  <<: *default
  database: beaker_ai_test
```

### Detailed Acceptance Criteria

**Scenario 1: App Boots Successfully**
**GIVEN** fresh Rails installation
**WHEN** running `rails server`
**THEN** server starts at localhost:3000
**AND** welcome page displays without errors

**Scenario 2: Database Connection Works**
**GIVEN** PostgreSQL running locally
**WHEN** running `rails db:create`
**THEN** databases created successfully
**AND** `rails db:migrate` runs without errors

**Scenario 3: Tailwind Compilation Works**
**GIVEN** Tailwind CSS installed
**WHEN** loading any page
**THEN** Tailwind styles apply
**AND** `bin/dev` starts both Rails + CSS watcher

**Scenario 4: Redis Connection Works**
**GIVEN** Redis server running
**WHEN** running `Redis.current.ping` in rails console
**THEN** returns "PONG"
**AND** no connection errors in logs

### TDD Approach
1. **No specs for this ticket** - it's infrastructure setup
2. **Manual verification:**
   - Run `rails server` and visit localhost:3000
   - Check `rails db:version` shows PostgreSQL
   - Run `Redis.current.ping` in console
3. **CI Setup:** Create `.github/workflows/ci.yml` for future tests

### Done Checklist
- [ ] `rails server` boots without errors
- [ ] `rails db:create` succeeds
- [ ] Tailwind CSS compiles (check browser inspector for classes)
- [ ] Redis connection works (`Redis.current.ping` returns "PONG")
- [ ] `.ruby-version` file specifies Ruby 3.3+
- [ ] `Gemfile.lock` checked in
- [ ] README updated with setup instructions

### Gotchas & Pitfalls
- **PostgreSQL not installed:** Install via Homebrew (Mac) or apt (Linux)
- **Redis not running:** Start with `redis-server` or `brew services start redis`
- **Port conflicts:** Rails uses 3000, Redis uses 6379 by default
- **Database permissions:** Ensure your DB user can create databases

### References
- start.md: Section 9 (Phase 0 requirements)
- BUILD-GUIDE.md: Appendix A (tech stack summary)

---

## TICKET: R1-E01-T002 - Configure Devise + Passwordless gem for magic-link auth

**Epic:** E-001: Rails Foundation & Infrastructure  
**Points:** 5  
**Priority:** P0  
**Dependencies:** R1-E01-T001

### Context & Why It Matters
Magic-link authentication reduces friction in trial signup (no password to remember = higher conversion). This pattern aligns with <60s trial goal from start.md. Mid-level complexity ticket combining Devise setup + passwordless customization.

### Implementation Hints
- **Gems to add:**
```ruby
# Gemfile
gem 'devise', '~> 4.9'
gem 'devise-passwordless', '~> 0.2'
```

- **Installation commands:**
```bash
rails generate devise:install
rails generate devise User
rails generate devise:passwordless:install
rails db:migrate
```

- **Key files to modify:**
```ruby
# app/models/user.rb
class User < ApplicationRecord
  devise :magic_link_authenticatable, :trackable
  
  validates :email, presence: true, uniqueness: true
  normalizes :email, with: -> email { email.strip.downcase }
end

# config/initializers/devise.rb
Devise.setup do |config|
  config.mailer_sender = 'noreply@beakerai.com'
  config.passwordless_login_within = 20.minutes
  config.paranoid = true  # Don't reveal if email exists
end
```

- **Mailer setup** (using SendGrid from BUILD-GUIDE.md Decision 1):
```ruby
# config/environments/development.rb
config.action_mailer.delivery_method = :letter_opener
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

# config/environments/test.rb
config.action_mailer.delivery_method = :test
config.action_mailer.default_url_options = { host: 'test.host' }
```

### Detailed Acceptance Criteria

**Scenario 1: User Requests Magic Link**
**GIVEN** user exists with email "user@example.com"
**WHEN** user visits `/users/sign_in` and submits email
**THEN** magic link email is sent within 3 seconds
**AND** email contains link to `/users/magic_link?token=xxx`
**AND** success message displays: "Check your email for login link"

**Scenario 2: User Clicks Magic Link (Valid Token)**
**GIVEN** user received magic link email
**WHEN** user clicks link within 20 minutes
**THEN** user is logged in (session created)
**AND** `current_user` returns User object
**AND** redirected to dashboard (or default path)

**Scenario 3: User Clicks Magic Link (Expired Token)**
**GIVEN** user received magic link email 21 minutes ago
**WHEN** user clicks link
**THEN** error message displays: "Login link expired"
**AND** user remains logged out
**AND** user can request new link

**Scenario 4: Email Normalization**
**GIVEN** user submits email "User+Test@Example.COM  "
**WHEN** processing login request
**THEN** email normalized to "user+test@example.com"
**AND** finds existing user regardless of case/spaces

### TDD Approach

1. **Write model spec first:**
```ruby
# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end
  
  describe 'email normalization' do
    it 'normalizes email to lowercase' do
      user = create(:user, email: 'User@Example.COM')
      expect(user.email).to eq('user@example.com')
    end
    
    it 'strips whitespace' do
      user = create(:user, email: '  user@example.com  ')
      expect(user.email).to eq('user@example.com')
    end
  end
  
  describe 'Devise modules' do
    it 'has magic_link_authenticatable module' do
      expect(User.devise_modules).to include(:magic_link_authenticatable)
    end
  end
end
```

2. **Write request spec for login flow:**
```ruby
# spec/requests/magic_link_auth_spec.rb
require 'rails_helper'

RSpec.describe 'Magic Link Authentication', type: :request do
  let(:user) { create(:user, email: 'test@example.com') }
  
  describe 'POST /users/sign_in' do
    it 'sends magic link email' do
      expect {
        post user_session_path, params: { user: { email: user.email } }
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
      
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:notice]).to match(/check your email/i)
    end
    
    it 'does not reveal if email exists (paranoid mode)' do
      post user_session_path, params: { user: { email: 'nonexistent@example.com' } }
      expect(flash[:notice]).to match(/check your email/i)  # Same message
    end
  end
  
  describe 'GET /users/magic_link' do
    it 'logs in user with valid token' do
      token = user.encode_passwordless_token
      
      get users_magic_link_path, params: { token: token }
      
      expect(controller.current_user).to eq(user)
      expect(response).to redirect_to(root_path)
    end
    
    it 'rejects expired token' do
      token = user.encode_passwordless_token
      travel 21.minutes
      
      get users_magic_link_path, params: { token: token }
      
      expect(controller.current_user).to be_nil
      expect(flash[:alert]).to match(/expired/i)
    end
  end
end
```

3. **Create FactoryBot factory:**
```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    
    trait :with_recent_login do
      current_sign_in_at { 5.minutes.ago }
    end
  end
end
```

4. **Manual testing:**
   - Start `letter_opener` gem and check email preview
   - Test with real email in staging
   - Verify token expiration after 20 minutes

### Done Checklist
- [ ] All specs pass (green)
- [ ] Magic link email sends in <3s in development (use letter_opener)
- [ ] Clicking link logs in user and sets session
- [ ] Expired links (>20min) show error and don't log in
- [ ] Email normalization works (case insensitive, strips whitespace)
- [ ] Paranoid mode enabled (same message for existing/non-existing emails)
- [ ] `current_user` helper available in controllers/views
- [ ] Test coverage >90% for User model and auth flow
- [ ] No N+1 queries (Bullet gem clean)

### Gotchas & Pitfalls
- **Email delivery in dev:** Use `letter_opener` gem, NOT real SMTP
- **Token encoding:** devise-passwordless handles this, don't roll your own
- **Session cookie:** Ensure `config.session_store` allows cross-tab login
- **Paranoid mode:** Don't leak user existence via different messages
- **Email normalization timing:** Must happen BEFORE uniqueness validation

### References
- start.md: Section 9.1 (Phase 0 ticket T0.01)
- BUILD-GUIDE.md: Decision 1 (SendGrid), Section 10.2 (Auth pattern)
- Devise docs: https://github.com/heartcombo/devise
- devise-passwordless docs: https://github.com/abevoelker/devise-passwordless

---

## TICKET: R1-E01-T003 - Set up Sidekiq + Redis for background jobs

**Epic:** E-001: Rails Foundation & Infrastructure  
**Points:** 3  
**Priority:** P0  
**Dependencies:** R1-E01-T001

### Context & Why It Matters
Sidekiq handles async work (API calls to Vapi, email sending, webhook processing). Choosing Sidekiq over Delayed Job or GoodJob because it's faster (threaded vs forked), has excellent monitoring UI, and mature ecosystem. Redis required as job queue backend.

### Implementation Hints
- **Gems to add:**
```ruby
# Gemfile
gem 'sidekiq', '~> 7.2'
gem 'redis', '~> 5.1'
```

- **Configuration files:**
```yaml
# config/sidekiq.yml
:concurrency: 5
:queues:
  - [critical, 3]  # Webhook processing
  - [default, 2]   # General jobs
  - [low, 1]       # Analytics, cleanup

# Retry configuration
:max_retries: 3
:dead_max_jobs: 10000
```

```ruby
# config/initializers/sidekiq.rb
Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1') }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1') }
end
```

- **Routes for web UI:**
```ruby
# config/routes.rb
require 'sidekiq/web'

Rails.application.routes.draw do
  # Protect with authentication later in Phase 4
  mount Sidekiq::Web => '/sidekiq'
end
```

- **Procfile for development:**
```yaml
# Procfile.dev
web: bin/rails server -p 3000
worker: bundle exec sidekiq
css: bin/rails tailwindcss:watch
```

### Detailed Acceptance Criteria

**Scenario 1: Sidekiq Processes Jobs**
**GIVEN** Sidekiq worker running
**WHEN** enqueuing job via `MyJob.perform_later`
**THEN** job processes within 5 seconds
**AND** job completes successfully (no errors)
**AND** Redis queue depth decreases

**Scenario 2: Queue Prioritization Works**
**GIVEN** jobs enqueued in critical, default, low queues
**WHEN** processing jobs
**THEN** critical jobs processed first (3:2:1 ratio)
**AND** no starvation of low priority jobs

**Scenario 3: Retry Logic Works**
**GIVEN** job fails with transient error
**WHEN** job raises exception
**THEN** job retries with exponential backoff
**AND** max 3 retries attempted
**AND** job moves to dead queue after max retries

**Scenario 4: Web UI Accessible**
**GIVEN** Rails server running
**WHEN** visiting `/sidekiq`
**THEN** Sidekiq dashboard loads
**AND** shows queue depths, processed count, failures
**AND** can view job details and retry failed jobs

### TDD Approach

1. **Write job spec template:**
```ruby
# spec/jobs/example_job_spec.rb
require 'rails_helper'

RSpec.describe ExampleJob, type: :job do
  include ActiveJob::TestHelper
  
  describe '#perform' do
    it 'enqueues job in default queue' do
      expect {
        ExampleJob.perform_later('arg1')
      }.to have_enqueued_job(ExampleJob).with('arg1').on_queue('default')
    end
    
    it 'processes job successfully' do
      allow(SomeService).to receive(:call).and_return(true)
      
      perform_enqueued_jobs do
        ExampleJob.perform_later('arg1')
      end
      
      expect(SomeService).to have_received(:call).with('arg1')
    end
  end
end
```

2. **Test retry behavior:**
```ruby
# spec/jobs/retry_job_spec.rb
require 'rails_helper'

RSpec.describe RetryJob, type: :job do
  it 'retries on transient failures' do
    allow(ExternalAPI).to receive(:call).and_raise(Net::ReadTimeout)
    
    expect {
      RetryJob.perform_now
    }.to raise_error(Net::ReadTimeout)
    
    # Job should be scheduled for retry
    expect(RetryJob).to have_been_enqueued.on_queue('default')
  end
end
```

3. **Manual testing:**
   - Create simple job that sleeps for 5 seconds
   - Enqueue job and verify it processes in Sidekiq UI
   - Kill job mid-processing and verify retry
   - Check Redis queue with `redis-cli` commands

### Done Checklist
- [ ] Sidekiq processes jobs within 5 seconds of enqueue
- [ ] Three queues configured: critical, default, low
- [ ] Priority ratios working (critical:default:low = 3:2:1)
- [ ] Web UI accessible at `/sidekiq`
- [ ] Retry logic working (3 attempts, exponential backoff)
- [ ] Dead queue captures failed jobs after max retries
- [ ] Redis connection stable (no disconnects in logs)
- [ ] `Procfile.dev` configured for `bin/dev` command
- [ ] Job specs template created in `spec/support/job_helpers.rb`

### Gotchas & Pitfalls
- **Redis DB collision:** Use different Redis DB numbers for dev (1), test (2), production (0)
- **Job arguments:** Must be JSON-serializable (no ActiveRecord objects directly)
- **Memory leaks:** Sidekiq is threaded, watch for shared state bugs
- **Dead queue growth:** Monitor and clear periodically (auto-expires after 6 months)
- **Web UI security:** MUST add authentication before deploying (Phase 4 admin panel)

### References
- start.md: Section 9.1 (Phase 0 ticket T0.02)
- BUILD-GUIDE.md: Pattern 3 (Job retry pattern)
- Sidekiq docs: https://github.com/sidekiq/sidekiq/wiki
- Sidekiq best practices: https://github.com/sidekiq/sidekiq/wiki/Best-Practices

---

## TICKET: R1-E01-T004 - Create base models: User, Trial, Assistant, Call, Business

**Epic:** E-001: Rails Foundation & Infrastructure  
**Points:** 5  
**Priority:** P0  
**Dependencies:** R1-E01-T001

### Context & Why It Matters
Core domain models represent the product's data structure. Using UUID primary keys (not auto-increment integers) for security and distributed system readiness. Proper associations, validations, and indexes from the start prevent painful migrations later.

### Implementation Hints

- **Enable UUID extension first:**
```ruby
# db/migrate/[timestamp]_enable_uuid.rb
class EnableUuid < ActiveRecord::Migration[7.1]
  def change
    enable_extension 'pgcrypto'  # For gen_random_uuid()
  end
end
```

- **User model (already created by Devise):**
```ruby
# db/migrate/[timestamp]_add_fields_to_users.rb
class AddFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :admin, :boolean, default: false, null: false
    add_index :users, :admin, where: "admin = true"
  end
end

# app/models/user.rb
class User < ApplicationRecord
  devise :magic_link_authenticatable, :trackable
  
  has_many :trials, dependent: :destroy
  has_many :business_ownerships, dependent: :destroy
  has_many :businesses, through: :business_ownerships
  
  validates :email, presence: true, uniqueness: true
  normalizes :email, with: -> email { email.strip.downcase }
  
  scope :admins, -> { where(admin: true) }
end
```

- **Trial model:**
```ruby
# db/migrate/[timestamp]_create_trials.rb
class CreateTrials < ActiveRecord::Migration[7.1]
  def change
    create_table :trials, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true, index: true
      
      # Persona data
      t.string :industry, null: false  # hvac, gym, dental
      t.string :business_name, null: false
      t.string :scenario, null: false  # lead_intake, faq, scheduling
      t.string :phone_e164, null: false  # User's phone for test call
      
      # Vapi assistant
      t.string :vapi_assistant_id, index: true
      t.jsonb :assistant_config, default: {}
      
      # Trial limits
      t.integer :calls_used, default: 0, null: false
      t.integer :calls_limit, default: 3, null: false
      
      # Status tracking
      t.string :status, default: 'pending', null: false  # pending, active, converted, expired
      t.timestamp :expires_at, null: false  # 48 hours from creation
      
      t.timestamps
    end
    
    add_index :trials, :status
    add_index :trials, :expires_at
    add_index :trials, [:user_id, :created_at]  # For user trial history
    add_check_constraint :trials, "calls_used <= calls_limit", name: "chk_calls_within_limit"
  end
end

# app/models/trial.rb
class Trial < ApplicationRecord
  belongs_to :user
  has_many :calls, dependent: :destroy
  
  enum status: { pending: 'pending', active: 'active', converted: 'converted', expired: 'expired' }
  enum industry: { hvac: 'hvac', gym: 'gym', dental: 'dental' }
  
  validates :business_name, :scenario, :phone_e164, presence: true
  validates :calls_used, numericality: { greater_than_or_equal_to: 0 }
  validate :calls_used_within_limit
  
  scope :active, -> { where(status: 'active').where('expires_at > ?', Time.current) }
  scope :expired_pending, -> { where(status: 'pending').where('expires_at < ?', Time.current) }
  
  before_validation :set_expires_at, on: :create
  
  def calls_remaining
    calls_limit - calls_used
  end
  
  def expired?
    expires_at < Time.current
  end
  
  private
  
  def set_expires_at
    self.expires_at ||= 48.hours.from_now
  end
  
  def calls_used_within_limit
    if calls_used > calls_limit
      errors.add(:calls_used, "cannot exceed limit of #{calls_limit}")
    end
  end
end
```

- **Call model:**
```ruby
# db/migrate/[timestamp]_create_calls.rb
class CreateCalls < ActiveRecord::Migration[7.1]
  def change
    create_table :calls, id: :uuid do |t|
      # Polymorphic owner (Trial or Business)
      t.references :callable, polymorphic: true, type: :uuid, null: false, index: true
      
      # Call metadata
      t.string :direction, null: false  # inbound, outbound_trial, outbound_lead
      t.string :to_e164, null: false
      t.string :from_e164
      t.string :status, default: 'initiated', null: false  # initiated, ringing, in_progress, completed, failed
      
      # External IDs
      t.string :vapi_call_id, index: true
      t.string :twilio_call_sid, index: true
      
      # Call outcome
      t.integer :duration_seconds
      t.text :transcript
      t.string :recording_url
      t.jsonb :extracted_lead, default: {}  # {name, phone, email, intent}
      
      # Costs
      t.decimal :vapi_cost, precision: 8, scale: 4
      t.decimal :twilio_cost, precision: 8, scale: 4
      t.decimal :openai_cost, precision: 8, scale: 4
      
      t.timestamps
      t.timestamp :started_at
      t.timestamp :ended_at
    end
    
    add_index :calls, :direction
    add_index :calls, :status
    add_index :calls, [:callable_type, :callable_id, :created_at]
    add_index :calls, :created_at  # For analytics queries
    
    # Prevent duplicate webhook processing
    add_index :calls, :vapi_call_id, unique: true, where: "vapi_call_id IS NOT NULL"
    add_index :calls, :twilio_call_sid, unique: true, where: "twilio_call_sid IS NOT NULL"
  end
end

# app/models/call.rb
class Call < ApplicationRecord
  belongs_to :callable, polymorphic: true
  
  enum direction: { inbound: 'inbound', outbound_trial: 'outbound_trial', outbound_lead: 'outbound_lead' }
  enum status: { initiated: 'initiated', ringing: 'ringing', in_progress: 'in_progress', completed: 'completed', failed: 'failed' }
  
  validates :to_e164, presence: true
  validates :vapi_call_id, uniqueness: true, allow_nil: true
  validates :twilio_call_sid, uniqueness: true, allow_nil: true
  
  scope :completed, -> { where(status: 'completed') }
  scope :today, -> { where('created_at >= ?', Time.current.beginning_of_day) }
  scope :for_business, ->(business_id) { where(callable_type: 'Business', callable_id: business_id) }
  
  def total_cost
    (vapi_cost || 0) + (twilio_cost || 0) + (openai_cost || 0)
  end
  
  def duration_minutes
    return nil unless duration_seconds
    (duration_seconds / 60.0).round(1)
  end
end
```

- **Business model (Phase 3, but define now for associations):**
```ruby
# db/migrate/[timestamp]_create_businesses.rb
class CreateBusinesses < ActiveRecord::Migration[7.1]
  def change
    create_table :businesses, id: :uuid do |t|
      t.string :name, null: false
      
      # Stripe subscription
      t.string :stripe_customer_id, null: false, index: { unique: true }
      t.string :stripe_subscription_id, index: true
      t.string :status, default: 'active', null: false  # active, past_due, canceled
      t.string :plan, null: false  # starter, pro
      
      # Plan limits
      t.integer :calls_included, null: false  # 100 or 500
      t.integer :calls_used_this_period, default: 0, null: false
      
      # Vapi assistant (created on subscription)
      t.string :vapi_assistant_id, index: true
      
      t.timestamps
    end
    
    add_index :businesses, :status
    add_index :businesses, :plan
  end
end

# app/models/business.rb
class Business < ApplicationRecord
  has_many :business_ownerships, dependent: :destroy
  has_many :owners, through: :business_ownerships, source: :user
  has_many :calls, as: :callable, dependent: :destroy
  has_one :phone_number, dependent: :destroy
  
  enum status: { active: 'active', past_due: 'past_due', canceled: 'canceled' }
  enum plan: { starter: 'starter', pro: 'pro' }
  
  validates :name, :stripe_customer_id, :plan, presence: true
  validates :stripe_customer_id, uniqueness: true
  validates :calls_included, numericality: { greater_than: 0 }
  
  before_validation :set_calls_included, on: :create
  
  def calls_remaining
    calls_included - calls_used_this_period
  end
  
  def over_limit?
    calls_used_this_period >= calls_included
  end
  
  private
  
  def set_calls_included
    self.calls_included ||= case plan
    when 'starter' then 100
    when 'pro' then 500
    else 100
    end
  end
end
```

- **Assistant model (optional, can be JSON in Trial/Business):**
```ruby
# Not creating separate model for MVP - store as jsonb in Trial/Business
# Vapi assistant config stored as JSON with these keys:
# {
#   voice_id: 'rachel',
#   first_message: 'Hi, this is Sarah...',
#   system_prompt: 'You are a helpful assistant...',
#   scenario: 'lead_intake',
#   max_duration_seconds: 120
# }
```

### Detailed Acceptance Criteria

**Scenario 1: Create Trial with Associations**
**GIVEN** user exists
**WHEN** creating trial with valid attributes
**THEN** trial saved to database
**AND** `trial.user` returns associated user
**AND** `user.trials` includes new trial
**AND** `expires_at` set to 48 hours from now

**Scenario 2: Call Belongs to Trial (Polymorphic)**
**GIVEN** trial exists
**WHEN** creating call with `callable: trial`
**THEN** call saved successfully
**AND** `call.callable` returns trial object
**AND** `trial.calls` includes new call

**Scenario 3: Validations Enforce Data Integrity**
**GIVEN** trial with 3 calls used (limit: 3)
**WHEN** incrementing calls_used to 4
**THEN** validation fails with error
**AND** database constraint prevents save

**Scenario 4: Scopes Filter Correctly**
**GIVEN** mix of active and expired trials
**WHEN** querying `Trial.active`
**THEN** returns only trials with status='active' AND expires_at > now
**AND** excludes expired trials

**Scenario 5: UUID Primary Keys Generated**
**GIVEN** creating any model
**WHEN** saving to database
**THEN** id is UUID string (e.g., "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11")
**AND** not auto-increment integer

### TDD Approach

1. **Write model specs for each model:**
```ruby
# spec/models/trial_spec.rb
require 'rails_helper'

RSpec.describe Trial, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:calls) }
  end
  
  describe 'validations' do
    it { should validate_presence_of(:business_name) }
    it { should validate_presence_of(:scenario) }
    it { should validate_presence_of(:phone_e164) }
    
    it 'enforces calls_used <= calls_limit' do
      trial = build(:trial, calls_used: 4, calls_limit: 3)
      expect(trial).not_to be_valid
      expect(trial.errors[:calls_used]).to include(/cannot exceed limit/)
    end
  end
  
  describe 'callbacks' do
    it 'sets expires_at on creation' do
      trial = create(:trial)
      expect(trial.expires_at).to be_within(1.second).of(48.hours.from_now)
    end
  end
  
  describe '#calls_remaining' do
    it 'calculates remaining calls' do
      trial = build(:trial, calls_used: 1, calls_limit: 3)
      expect(trial.calls_remaining).to eq(2)
    end
  end
  
  describe '#expired?' do
    it 'returns true if past expiration' do
      trial = build(:trial, expires_at: 1.hour.ago)
      expect(trial).to be_expired
    end
    
    it 'returns false if not expired' do
      trial = build(:trial, expires_at: 1.hour.from_now)
      expect(trial).not_to be_expired
    end
  end
  
  describe 'scopes' do
    let!(:active_trial) { create(:trial, status: 'active', expires_at: 1.hour.from_now) }
    let!(:expired_trial) { create(:trial, status: 'active', expires_at: 1.hour.ago) }
    
    it '.active returns only non-expired trials' do
      expect(Trial.active).to include(active_trial)
      expect(Trial.active).not_to include(expired_trial)
    end
  end
end
```

```ruby
# spec/models/call_spec.rb
require 'rails_helper'

RSpec.describe Call, type: :model do
  describe 'polymorphic associations' do
    it 'belongs to trial as callable' do
      trial = create(:trial)
      call = create(:call, callable: trial)
      expect(call.callable).to eq(trial)
      expect(trial.calls).to include(call)
    end
    
    it 'belongs to business as callable (future)' do
      business = create(:business)
      call = create(:call, callable: business)
      expect(call.callable).to eq(business)
    end
  end
  
  describe 'validations' do
    it { should validate_presence_of(:to_e164) }
    it { should validate_uniqueness_of(:vapi_call_id).allow_nil }
    it { should validate_uniqueness_of(:twilio_call_sid).allow_nil }
  end
  
  describe '#total_cost' do
    it 'sums all cost fields' do
      call = build(:call, vapi_cost: 0.50, twilio_cost: 0.05, openai_cost: 0.02)
      expect(call.total_cost).to eq(0.57)
    end
    
    it 'handles nil costs' do
      call = build(:call, vapi_cost: nil, twilio_cost: 0.05)
      expect(call.total_cost).to eq(0.05)
    end
  end
end
```

2. **Create FactoryBot factories:**
```ruby
# spec/factories/trials.rb
FactoryBot.define do
  factory :trial do
    user
    industry { 'hvac' }
    business_name { Faker::Company.name }
    scenario { 'lead_intake' }
    phone_e164 { "+1#{Faker::Number.number(digits: 10)}" }
    status { 'pending' }
    calls_used { 0 }
    calls_limit { 3 }
    expires_at { 48.hours.from_now }
    
    trait :active do
      status { 'active' }
      vapi_assistant_id { "asst_#{SecureRandom.hex(12)}" }
    end
    
    trait :expired do
      status { 'expired' }
      expires_at { 1.hour.ago }
    end
    
    trait :with_calls do
      after(:create) do |trial|
        create_list(:call, 2, callable: trial)
      end
    end
  end
end

# spec/factories/calls.rb
FactoryBot.define do
  factory :call do
    association :callable, factory: :trial
    direction { 'outbound_trial' }
    to_e164 { "+1#{Faker::Number.number(digits: 10)}" }
    status { 'initiated' }
    
    trait :completed do
      status { 'completed' }
      duration_seconds { rand(30..300) }
      started_at { 5.minutes.ago }
      ended_at { 2.minutes.ago }
      vapi_call_id { "call_#{SecureRandom.hex(16)}" }
      twilio_call_sid { "CA#{SecureRandom.hex(16)}" }
    end
    
    trait :with_transcript do
      completed
      transcript { "Agent: Hi, this is Sarah. How can I help?\nCustomer: I need a quote." }
      extracted_lead { { name: 'John Doe', phone: '+15555551234', intent: 'quote' } }
    end
  end
end

# spec/factories/businesses.rb
FactoryBot.define do
  factory :business do
    name { Faker::Company.name }
    stripe_customer_id { "cus_#{SecureRandom.hex(12)}" }
    stripe_subscription_id { "sub_#{SecureRandom.hex(12)}" }
    plan { 'starter' }
    status { 'active' }
    
    trait :pro_plan do
      plan { 'pro' }
      calls_included { 500 }
    end
    
    trait :with_owner do
      after(:create) do |business|
        user = create(:user)
        create(:business_ownership, business: business, user: user)
      end
    end
  end
end
```

3. **Test migrations in isolation:**
```bash
# Test migrations rollback/forward
rails db:migrate VERSION=0  # Rollback all
rails db:migrate             # Migrate forward
rails db:schema:load         # Load from schema.rb

# Verify constraints in psql
psql beaker_ai_development
\d trials;  # Show table structure with constraints
```

### Done Checklist
- [ ] All migrations run without errors
- [ ] UUID primary keys on all tables (not integer auto-increment)
- [ ] Foreign keys defined with proper indexes
- [ ] Unique constraints on vapi_call_id, twilio_call_sid, stripe_customer_id
- [ ] Check constraint on trials.calls_used <= calls_limit
- [ ] Polymorphic associations work (Call belongs to Trial or Business)
- [ ] All model specs passing (validations, associations, scopes)
- [ ] FactoryBot factories created for all models
- [ ] Database indexes on foreign keys and frequently queried columns
- [ ] Enums defined for status, direction, industry, plan
- [ ] No N+1 queries in association tests (Bullet clean)
- [ ] Schema.rb generated and checked in

### Gotchas & Pitfalls
- **UUID vs Integer:** Must enable `pgcrypto` extension first
- **Polymorphic foreign keys:** Must be `type: :uuid` to match parent UUIDs
- **Enum strings vs symbols:** Rails 7 uses strings by default, stay consistent
- **Null constraints:** Add `null: false` for required fields to enforce at DB level
- **Unique constraints on nullable columns:** Use partial indexes with WHERE clause
- **Factory associations:** Use `association :callable, factory: :trial` for polymorphic
- **Migration rollback:** Test `rails db:rollback` works before committing

### References
- start.md: Section 9.1 (Phase 0 models), Section 14.5 (Quick reference patterns)
- BUILD-GUIDE.md: Section 10.1 (Race condition prevention pattern)
- Rails guides: https://guides.rubyonrails.org/active_record_migrations.html
- UUID primary keys: https://pawelurbanek.com/uuid-order-rails

---

## TICKET: R1-E01-T005 - Implement CircuitBreaker wrapper for API clients

**Epic:** E-001: Rails Foundation & Infrastructure  
**Points:** 5  
**Priority:** P0  
**Dependencies:** R1-E01-T003

### Context & Why It Matters
Circuit breakers prevent cascade failures when external APIs (Vapi, Twilio, Stripe) go down. Without this, our app would keep hammering failing APIs, wasting resources and making problems worse. Using Stoplight gem (mature, battle-tested). This is CRITICAL for production stability - one of the non-negotiables from start.md Executive Summary.

### Implementation Hints

- **Gem to add:**
```ruby
# Gemfile
gem 'stoplight', '~> 4.0'
```

- **Configuration:**
```ruby
# config/initializers/stoplight.rb
require 'stoplight'
require 'stoplight/light/runnable'

# Use Redis for distributed circuit breaker state
Stoplight::Light.default_data_store = Stoplight::DataStore::Redis.new(Redis.current)

# Configure notifications (integrate with Sentry)
Stoplight::Light.default_notifiers = [
  Stoplight::Notifier::Generic.new do |light, from_color, to_color, error|
    if to_color == Stoplight::Color::RED
      Sentry.capture_message(
        "Circuit breaker opened: #{light.name}",
        level: :error,
        extra: {
          light_name: light.name,
          from_color: from_color,
          to_color: to_color,
          error: error.inspect
        }
      )
    elsif to_color == Stoplight::Color::GREEN
      Sentry.capture_message(
        "Circuit breaker recovered: #{light.name}",
        level: :info
      )
    end
  end
]

# Circuit breaker defaults
Stoplight::Light.default_threshold = 5      # Open after 5 failures
Stoplight::Light.default_timeout = 60       # Auto-reset after 60 seconds
Stoplight::Light.default_cooldown = 300     # Stay open for 5 minutes after threshold
```

- **Base API client pattern:**
```ruby
# app/services/api_client_base.rb
class ApiClientBase
  class CircuitOpenError < StandardError; end
  class ApiError < StandardError; end
  
  def with_circuit_breaker(name:, fallback: nil, &block)
    light = Stoplight(name) do
      block.call
    end
    .with_threshold(5)
    .with_timeout(60)
    .with_fallback do |error|
      Rails.logger.error("[CircuitBreaker] #{name} is open: #{error.message}")
      
      if fallback
        fallback.call
      else
        raise CircuitOpenError, "#{name} circuit breaker is open"
      end
    end
    
    light.run
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
```

- **Vapi client with circuit breaker:**
```ruby
# app/services/vapi_client.rb
class VapiClient < ApiClientBase
  def initialize
    @api_key = ENV.fetch('VAPI_API_KEY')
    @base_url = 'https://api.vapi.ai'
  end
  
  def create_assistant(config:)
    with_circuit_breaker(name: 'vapi:create_assistant') do
      with_retry(attempts: 3) do
        response = HTTP.auth("Bearer #{@api_key}")
                      .post("#{@base_url}/assistant", json: config)
        
        raise ApiError, "Vapi API error: #{response.status}" unless response.status.success?
        
        JSON.parse(response.body)
      end
    end
  end
  
  def get_call(call_id:)
    with_circuit_breaker(name: 'vapi:get_call', fallback: -> { nil }) do
      response = HTTP.auth("Bearer #{@api_key}")
                    .get("#{@base_url}/call/#{call_id}")
      
      return nil unless response.status.success?
      
      JSON.parse(response.body)
    end
  end
  
  # Other methods: update_assistant, delete_assistant, etc.
end
```

- **Twilio client with circuit breaker:**
```ruby
# app/services/twilio_client.rb
class TwilioClient < ApiClientBase
  def initialize
    @account_sid = ENV.fetch('TWILIO_ACCOUNT_SID')
    @auth_token = ENV.fetch('TWILIO_AUTH_TOKEN')
    @client = Twilio::REST::Client.new(@account_sid, @auth_token)
  end
  
  def place_call(to:, from:, url:)
    with_circuit_breaker(name: 'twilio:place_call') do
      with_retry(attempts: 3) do
        @client.calls.create(
          to: to,
          from: from,
          url: url,
          status_callback: ENV.fetch('TWILIO_STATUS_CALLBACK_URL'),
          status_callback_event: ['initiated', 'ringing', 'answered', 'completed']
        )
      end
    end
  end
  
  def provision_number(area_code: nil)
    with_circuit_breaker(name: 'twilio:provision_number') do
      search_params = { country_code: 'US' }
      search_params[:area_code] = area_code if area_code
      
      available_numbers = @client.available_phone_numbers('US').local.list(search_params)
      raise ApiError, 'No available numbers' if available_numbers.empty?
      
      number = @client.incoming_phone_numbers.create(
        phone_number: available_numbers.first.phone_number,
        voice_url: ENV.fetch('TWILIO_VOICE_URL')
      )
      
      number
    end
  end
end
```

- **Stripe client with circuit breaker:**
```ruby
# app/services/stripe_client.rb
class StripeClient < ApiClientBase
  def initialize
    Stripe.api_key = ENV.fetch('STRIPE_API_KEY')
  end
  
  def create_checkout_session(price_id:, customer_email:, metadata: {})
    with_circuit_breaker(name: 'stripe:create_checkout_session') do
      Stripe::Checkout::Session.create(
        mode: 'subscription',
        line_items: [{ price: price_id, quantity: 1 }],
        customer_email: customer_email,
        success_url: ENV.fetch('STRIPE_SUCCESS_URL'),
        cancel_url: ENV.fetch('STRIPE_CANCEL_URL'),
        metadata: metadata
      )
    end
  end
  
  def get_subscription(subscription_id:)
    with_circuit_breaker(name: 'stripe:get_subscription', fallback: -> { nil }) do
      Stripe::Subscription.retrieve(subscription_id)
    end
  rescue Stripe::InvalidRequestError
    nil  # Subscription not found
  end
end
```

- **Admin health check integration:**
```ruby
# app/controllers/admin/health_controller.rb
class Admin::HealthController < Admin::BaseController
  def circuit_breakers
    circuits = [
      { name: 'vapi:create_assistant', light: Stoplight('vapi:create_assistant') },
      { name: 'twilio:place_call', light: Stoplight('twilio:place_call') },
      { name: 'stripe:create_checkout_session', light: Stoplight('stripe:create_checkout_session') }
    ]
    
    @circuit_status = circuits.map do |circuit|
      {
        name: circuit[:name],
        color: circuit[:light].color,
        failures: circuit[:light].data_store.get_failures(circuit[:light]),
        last_failure_time: circuit[:light].data_store.get_last_failure_time(circuit[:light])
      }
    end
    
    render json: @circuit_status
  end
end
```

### Detailed Acceptance Criteria

**Scenario 1: Circuit Breaker Opens After Failures**
**GIVEN** Vapi API is down (raising Net::ReadTimeout)
**WHEN** making 5 consecutive create_assistant calls
**THEN** circuit breaker opens (state: RED)
**AND** subsequent calls raise CircuitOpenError without hitting API
**AND** Sentry alert fires with "Circuit breaker opened: vapi:create_assistant"

**Scenario 2: Circuit Breaker Auto-Resets**
**GIVEN** circuit breaker is open
**WHEN** 60 seconds pass
**THEN** circuit attempts test request (half-open state)
**AND** if request succeeds, circuit closes (state: GREEN)
**AND** if request fails, circuit reopens for another 60s

**Scenario 3: Fallback Function Executes**
**GIVEN** circuit breaker open for get_call
**WHEN** calling VapiClient.get_call(call_id: 'xxx')
**THEN** fallback function returns nil (not exception)
**AND** app continues without crashing

**Scenario 4: Retry Logic Works for Transient Errors**
**GIVEN** Twilio API returns Net::ReadTimeout on first 2 attempts
**WHEN** calling place_call with retry
**THEN** retries 3 times with exponential backoff (1s, 2s, 4s)
**AND** succeeds on 3rd attempt
**AND** no circuit breaker trip (transient error handled)

**Scenario 5: Circuit State Visible in Admin**
**GIVEN** admin user
**WHEN** GET /admin/health/circuit_breakers
**THEN** JSON shows all circuits with color (green/yellow/red)
**AND** failure count and last failure time for each

### TDD Approach

1. **Write service specs with mocked failures:**
```ruby
# spec/services/vapi_client_spec.rb
require 'rails_helper'

RSpec.describe VapiClient do
  let(:client) { described_class.new }
  
  describe '#create_assistant' do
    let(:config) { { name: 'Test Assistant', voice_id: 'rachel' } }
    
    context 'when API succeeds' do
      it 'returns assistant data' do
        stub_request(:post, 'https://api.vapi.ai/assistant')
          .to_return(status: 200, body: { id: 'asst_123', name: 'Test' }.to_json)
        
        result = client.create_assistant(config: config)
        
        expect(result['id']).to eq('asst_123')
      end
    end
    
    context 'when API fails transiently' do
      it 'retries and succeeds' do
        stub_request(:post, 'https://api.vapi.ai/assistant')
          .to_timeout.times(2)  # First 2 attempts timeout
          .then
          .to_return(status: 200, body: { id: 'asst_123' }.to_json)  # 3rd succeeds
        
        result = nil
        expect {
          result = client.create_assistant(config: config)
        }.not_to raise_error
        
        expect(result['id']).to eq('asst_123')
        expect(WebMock).to have_requested(:post, 'https://api.vapi.ai/assistant').times(3)
      end
    end
    
    context 'when circuit breaker opens' do
      before do
        # Trigger 5 failures to open circuit
        stub_request(:post, 'https://api.vapi.ai/assistant').to_timeout
        5.times do
          begin
            client.create_assistant(config: config)
          rescue => e
            # Expected failures
          end
        end
      end
      
      it 'raises CircuitOpenError without hitting API' do
        # This request should not hit the API (circuit is open)
        expect {
          client.create_assistant(config: config)
        }.to raise_error(ApiClientBase::CircuitOpenError, /circuit breaker is open/)
        
        # Verify API was not called this time (still 5 from before)
        expect(WebMock).to have_requested(:post, 'https://api.vapi.ai/assistant').times(5)
      end
      
      it 'resets after timeout' do
        # Wait for circuit to half-open (60 seconds in test, can reduce with config)
        travel 61.seconds
        
        # Circuit should attempt request again
        stub_request(:post, 'https://api.vapi.ai/assistant')
          .to_return(status: 200, body: { id: 'asst_123' }.to_json)
        
        result = client.create_assistant(config: config)
        expect(result['id']).to eq('asst_123')
      end
    end
  end
  
  describe '#get_call with fallback' do
    it 'returns nil when circuit is open' do
      stub_request(:get, %r{https://api.vapi.ai/call/.*}).to_timeout
      
      # Open circuit
      5.times do
        begin
          client.get_call(call_id: 'call_123')
        rescue => e
          # Expected
        end
      end
      
      # Fallback should return nil, not raise
      result = client.get_call(call_id: 'call_123')
      expect(result).to be_nil
    end
  end
end
```

2. **Test Sentry notification integration:**
```ruby
# spec/services/circuit_breaker_notifications_spec.rb
require 'rails_helper'

RSpec.describe 'Circuit Breaker Notifications' do
  before do
    allow(Sentry).to receive(:capture_message)
  end
  
  it 'sends Sentry alert when circuit opens' do
    client = VapiClient.new
    stub_request(:post, 'https://api.vapi.ai/assistant').to_timeout
    
    # Trigger failures to open circuit
    5.times do
      begin
        client.create_assistant(config: {})
      rescue => e
        # Expected
      end
    end
    
    expect(Sentry).to have_received(:capture_message).with(
      /Circuit breaker opened: vapi:create_assistant/,
      hash_including(level: :error)
    )
  end
  
  it 'sends Sentry info when circuit recovers' do
    # Open circuit first
    client = VapiClient.new
    stub_request(:post, 'https://api.vapi.ai/assistant').to_timeout
    5.times { client.create_assistant(config: {}) rescue nil }
    
    # Wait and recover
    travel 61.seconds
    stub_request(:post, 'https://api.vapi.ai/assistant')
      .to_return(status: 200, body: {}.to_json)
    
    client.create_assistant(config: {})
    
    expect(Sentry).to have_received(:capture_message).with(
      /Circuit breaker recovered: vapi:create_assistant/,
      hash_including(level: :info)
    )
  end
end
```

3. **Manual testing checklist:**
- Start Redis (`redis-server`)
- Use `rails console` to trigger failures manually
- Check Sentry dashboard for alerts
- Verify circuit state in Redis: `redis-cli KEYS "stoplight:*"`
- Test half-open state by advancing time

### Done Checklist
- [ ] Stoplight gem installed and configured
- [ ] Redis data store configured for distributed state
- [ ] Circuit breaker opens after 5 failures within 60s
- [ ] Circuit auto-resets after 60s timeout
- [ ] Sentry notifications fire on circuit state changes (open/recover)
- [ ] ApiClientBase implements with_circuit_breaker and with_retry methods
- [ ] VapiClient, TwilioClient, StripeClient inherit from ApiClientBase
- [ ] Fallback functions work (return nil vs exception where appropriate)
- [ ] Retry logic uses exponential backoff (1s, 2s, 4s)
- [ ] Admin health endpoint shows circuit breaker status
- [ ] All specs passing (with WebMock stubs)
- [ ] Manual testing confirms circuit opens/closes in dev

### Gotchas & Pitfalls
- **Redis requirement:** Circuit breaker state stored in Redis, must be running
- **Threshold tuning:** 5 failures may be too sensitive, adjust based on SLO
- **Cooldown vs Timeout:** Timeout = when to try again, Cooldown = how long to stay open
- **Distributed state:** In multi-dyno setup, Redis ensures all workers see same circuit state
- **Testing time:** Use `travel` helper to advance time, don't `sleep` in tests
- **Fallback complexity:** Keep fallbacks simple (return nil, empty array), not business logic
- **Error classification:** Only wrap transient errors (timeouts, connection errors), not 400/401

### References
- start.md: Section 4.3 (Circuit Breaker Playbook), Section 14.5 (Quick reference patterns)
- BUILD-GUIDE.md: Pattern 2 (Circuit breaker pattern)
- Stoplight docs: https://github.com/bolshakov/stoplight
- Circuit breaker pattern: https://martinfowler.com/bliki/CircuitBreaker.html

---

## TICKET: R1-E01-T006 - Build webhook receiver framework with signature verification

**Epic:** E-001: Rails Foundation & Infrastructure  
**Points:** 5  
**Priority:** P0  
**Dependencies:** R1-E01-T003, R1-E01-T004

### Context & Why It Matters
Webhooks from Stripe, Twilio, and Vapi drive core product functionality (payment processing, call status updates). Without signature verification, attackers could forge webhooks and create fake subscriptions or manipulate call data. Idempotency prevents duplicate processing from retries. This is CRITICAL SECURITY infrastructure.

### Implementation Hints

- **Base webhook controller:**
```ruby
# app/controllers/webhooks_controller.rb
class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token  # Webhooks don't have CSRF tokens
  before_action :verify_signature
  
  def create
    event = WebhookEvent.find_or_create_by!(
      provider: params[:provider],
      event_id: webhook_event_id,
      event_type: webhook_event_type,
      payload: webhook_payload
    )
    
    if event.previously_new_record?
      # First time seeing this event, enqueue processing job
      WebhookProcessorJob.perform_later(event.id)
      Rails.logger.info("[Webhook] New #{params[:provider]} event: #{event.event_type} (#{event.event_id})")
    else
      # Duplicate event, already processed or processing
      Rails.logger.info("[Webhook] Duplicate #{params[:provider]} event: #{event.event_type} (#{event.event_id})")
    end
    
    head :ok
  rescue => e
    Sentry.capture_exception(e, extra: { provider: params[:provider], payload: request.body.read })
    head :internal_server_error
  end
  
  private
  
  def verify_signature
    case params[:provider]
    when 'stripe'
      verify_stripe_signature
    when 'twilio'
      verify_twilio_signature
    when 'vapi'
      verify_vapi_signature
    else
      head :not_found
    end
  end
  
  def verify_stripe_signature
    payload = request.body.read
    sig_header = request.headers['Stripe-Signature']
    
    begin
      Stripe::Webhook.construct_event(
        payload,
        sig_header,
        ENV.fetch('STRIPE_WEBHOOK_SECRET')
      )
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error("[Webhook] Stripe signature verification failed: #{e.message}")
      head :unauthorized
    end
  end
  
  def verify_twilio_signature
    # Twilio uses X-Twilio-Signature header with HMAC SHA1
    signature = request.headers['X-Twilio-Signature']
    url = request.original_url
    
    validator = Twilio::Security::RequestValidator.new(ENV.fetch('TWILIO_AUTH_TOKEN'))
    
    unless validator.validate(url, request.POST, signature)
      Rails.logger.error("[Webhook] Twilio signature verification failed")
      head :unauthorized
    end
  end
  
  def verify_vapi_signature
    # Vapi uses HMAC SHA256 in x-vapi-signature header
    signature = request.headers['x-vapi-signature']
    payload = request.body.read
    secret = ENV.fetch('VAPI_WEBHOOK_SECRET')
    
    expected_signature = OpenSSL::HMAC.hexdigest('SHA256', secret, payload)
    
    unless Rack::Utils.secure_compare(expected_signature, signature)
      Rails.logger.error("[Webhook] Vapi signature verification failed")
      head :unauthorized
    end
  end
  
  def webhook_event_id
    case params[:provider]
    when 'stripe'
      JSON.parse(request.body.read)['id']
    when 'twilio'
      params['CallSid'] || params['MessageSid']
    when 'vapi'
      JSON.parse(request.body.read)['message']['id']
    end
  end
  
  def webhook_event_type
    case params[:provider]
    when 'stripe'
      JSON.parse(request.body.read)['type']
    when 'twilio'
      params['CallStatus'] ? 'call_status' : 'message_status'
    when 'vapi'
      JSON.parse(request.body.read)['message']['type']
    end
  end
  
  def webhook_payload
    JSON.parse(request.body.read)
  rescue JSON::ParserError
    request.POST.to_h  # Twilio sends form-encoded data
  end
end
```

- **WebhookEvent model:**
```ruby
# db/migrate/[timestamp]_create_webhook_events.rb
class CreateWebhookEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :webhook_events, id: :uuid do |t|
      t.string :provider, null: false  # stripe, twilio, vapi
      t.string :event_id, null: false  # Unique ID from provider
      t.string :event_type, null: false  # checkout.session.completed, call.ended, etc.
      t.jsonb :payload, null: false, default: {}
      t.string :status, default: 'pending', null: false  # pending, processing, completed, failed
      t.integer :retries, default: 0, null: false
      t.text :error_message
      t.timestamp :processed_at
      t.timestamps
      
      # Idempotency constraint: one event per provider+event_id
      t.index [:provider, :event_id], unique: true, name: 'idx_unique_webhook_event'
      
      t.index :provider
      t.index :event_type
      t.index :status
      t.index :created_at
    end
  end
end

# app/models/webhook_event.rb
class WebhookEvent < ApplicationRecord
  enum status: { pending: 'pending', processing: 'processing', completed: 'completed', failed: 'failed' }
  enum provider: { stripe: 'stripe', twilio: 'twilio', vapi: 'vapi' }
  
  validates :event_id, :event_type, presence: true
  validates :event_id, uniqueness: { scope: :provider }
  
  scope :unprocessed, -> { where(status: ['pending', 'failed']).where('retries < ?', 3) }
  scope :recent, -> { where('created_at > ?', 7.days.ago) }
  
  def mark_processing!
    update!(status: 'processing', processed_at: Time.current)
  end
  
  def mark_completed!
    update!(status: 'completed')
  end
  
  def mark_failed!(error)
    update!(
      status: 'failed',
      error_message: error.message,
      retries: retries + 1
    )
  end
end
```

- **WebhookProcessorJob:**
```ruby
# app/jobs/webhook_processor_job.rb
class WebhookProcessorJob < ApplicationJob
  queue_as :critical  # High priority queue
  
  retry_on StandardError, wait: :exponentially_longer, attempts: 3
  
  def perform(webhook_event_id)
    event = WebhookEvent.find(webhook_event_id)
    
    # Skip if already processed
    return if event.completed?
    
    event.mark_processing!
    
    # Route to specific processor based on provider and type
    processor = case [event.provider, event.event_type]
    when ['stripe', /checkout\.session\.completed/]
      Webhooks::Stripe::CheckoutSessionProcessor.new(event)
    when ['stripe', /customer\.subscription\./]
      Webhooks::Stripe::SubscriptionProcessor.new(event)
    when ['twilio', 'call_status']
      Webhooks::Twilio::CallStatusProcessor.new(event)
    when ['vapi', /call\./]
      Webhooks::Vapi::CallProcessor.new(event)
    else
      Rails.logger.warn("[Webhook] No processor for #{event.provider}:#{event.event_type}")
      event.mark_completed!  # Prevent retry loop for unknown events
      return
    end
    
    processor.process
    event.mark_completed!
    
    Rails.logger.info("[Webhook] Processed #{event.provider}:#{event.event_type} (#{event.event_id})")
  rescue => e
    event.mark_failed!(e)
    Sentry.capture_exception(e, extra: { webhook_event_id: webhook_event_id })
    raise  # Let ActiveJob retry handle it
  end
end
```

- **Routes:**
```ruby
# config/routes.rb
Rails.application.routes.draw do
  # Webhook endpoints (one per provider for clear logging)
  post '/webhooks/stripe', to: 'webhooks#create', defaults: { provider: 'stripe' }
  post '/webhooks/twilio', to: 'webhooks#create', defaults: { provider: 'twilio' }
  post '/webhooks/vapi', to: 'webhooks#create', defaults: { provider: 'vapi' }
end
```

### Detailed Acceptance Criteria

**Scenario 1: Stripe Webhook with Valid Signature**
**GIVEN** Stripe sends checkout.session.completed webhook
**WHEN** POST /webhooks/stripe with valid Stripe-Signature header
**THEN** WebhookEvent record created with event_id, event_type, payload
**AND** WebhookProcessorJob enqueued
**AND** response is 200 OK

**Scenario 2: Stripe Webhook with Invalid Signature**
**GIVEN** Attacker forges Stripe webhook
**WHEN** POST /webhooks/stripe with invalid/missing Stripe-Signature
**THEN** request rejected with 401 Unauthorized
**AND** no WebhookEvent created
**AND** error logged to Sentry

**Scenario 3: Duplicate Webhook (Idempotency)**
**GIVEN** Stripe webhook already processed (event_id exists in DB)
**WHEN** Stripe retries same webhook (common during network issues)
**THEN** WebhookEvent found by unique constraint (provider + event_id)
**AND** no duplicate WebhookProcessorJob enqueued
**AND** logs "Duplicate webhook" message
**AND** response is 200 OK (idempotent)

**Scenario 4: Twilio Webhook with X-Twilio-Signature**
**GIVEN** Twilio sends call status webhook
**WHEN** POST /webhooks/twilio with valid X-Twilio-Signature
**THEN** signature validated using Twilio::Security::RequestValidator
**AND** WebhookEvent created
**AND** response is 200 OK

**Scenario 5: Vapi Webhook with HMAC**
**GIVEN** Vapi sends call.ended webhook
**WHEN** POST /webhooks/vapi with x-vapi-signature header
**THEN** HMAC SHA256 signature validated
**AND** WebhookEvent created
**AND** response is 200 OK

**Scenario 6: Webhook Processing Failure and Retry**
**GIVEN** WebhookEvent with status=pending
**WHEN** WebhookProcessorJob raises exception during processing
**THEN** event.status = 'failed'
**AND** event.retries incremented
**AND** event.error_message saved
**AND** ActiveJob retries job with exponential backoff

### TDD Approach

1. **Write request specs for each provider:**
```ruby
# spec/requests/webhooks/stripe_spec.rb
require 'rails_helper'

RSpec.describe 'Stripe Webhooks', type: :request do
  let(:payload) do
    {
      id: 'evt_test_webhook',
      object: 'event',
      type: 'checkout.session.completed',
      data: {
        object: {
          id: 'cs_test_session',
          customer_email: 'test@example.com',
          metadata: { user_id: '123' }
        }
      }
    }.to_json
  end
  
  let(:secret) { ENV['STRIPE_WEBHOOK_SECRET'] || 'whsec_test_secret' }
  
  def generate_stripe_signature(payload, secret)
    timestamp = Time.now.to_i
    signed_payload = "#{timestamp}.#{payload}"
    signature = OpenSSL::HMAC.hexdigest('SHA256', secret, signed_payload)
    "t=#{timestamp},v1=#{signature}"
  end
  
  describe 'POST /webhooks/stripe' do
    context 'with valid signature' do
      it 'creates webhook event and enqueues job' do
        signature = generate_stripe_signature(payload, secret)
        
        expect {
          post '/webhooks/stripe',
               params: payload,
               headers: {
                 'Content-Type' => 'application/json',
                 'Stripe-Signature' => signature
               }
        }.to change(WebhookEvent, :count).by(1)
         .and have_enqueued_job(WebhookProcessorJob)
        
        expect(response).to have_http_status(:ok)
        
        event = WebhookEvent.last
        expect(event.provider).to eq('stripe')
        expect(event.event_id).to eq('evt_test_webhook')
        expect(event.event_type).to eq('checkout.session.completed')
        expect(event.status).to eq('pending')
      end
    end
    
    context 'with invalid signature' do
      it 'rejects request with 401' do
        expect {
          post '/webhooks/stripe',
               params: payload,
               headers: {
                 'Content-Type' => 'application/json',
                 'Stripe-Signature' => 'invalid_signature'
               }
        }.not_to change(WebhookEvent, :count)
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
    
    context 'with duplicate event' do
      before do
        create(:webhook_event, provider: 'stripe', event_id: 'evt_test_webhook')
      end
      
      it 'returns 200 but does not enqueue duplicate job' do
        signature = generate_stripe_signature(payload, secret)
        
        expect {
          post '/webhooks/stripe',
               params: payload,
               headers: {
                 'Content-Type' => 'application/json',
                 'Stripe-Signature' => signature
               }
        }.not_to change(WebhookEvent, :count)
         .and not_have_enqueued_job(WebhookProcessorJob)
        
        expect(response).to have_http_status(:ok)
      end
    end
  end
end

# Similar specs for twilio_spec.rb and vapi_spec.rb
```

2. **Write job spec:**
```ruby
# spec/jobs/webhook_processor_job_spec.rb
require 'rails_helper'

RSpec.describe WebhookProcessorJob, type: :job do
  let(:webhook_event) { create(:webhook_event, provider: 'stripe', event_type: 'checkout.session.completed') }
  
  describe '#perform' do
    context 'when processing succeeds' do
      it 'marks event as completed' do
        allow_any_instance_of(Webhooks::Stripe::CheckoutSessionProcessor).to receive(:process)
        
        perform_enqueued_jobs do
          WebhookProcessorJob.perform_later(webhook_event.id)
        end
        
        webhook_event.reload
        expect(webhook_event.status).to eq('completed')
        expect(webhook_event.processed_at).to be_present
      end
    end
    
    context 'when processing fails' do
      it 'marks event as failed and increments retries' do
        allow_any_instance_of(Webhooks::Stripe::CheckoutSessionProcessor)
          .to receive(:process).and_raise(StandardError, 'Processing error')
        
        expect {
          perform_enqueued_jobs do
            WebhookProcessorJob.perform_later(webhook_event.id)
          end
        }.to raise_error(StandardError)
        
        webhook_event.reload
        expect(webhook_event.status).to eq('failed')
        expect(webhook_event.retries).to eq(1)
        expect(webhook_event.error_message).to include('Processing error')
      end
    end
    
    context 'with duplicate completed event' do
      before { webhook_event.update!(status: 'completed') }
      
      it 'skips processing' do
        expect_any_instance_of(Webhooks::Stripe::CheckoutSessionProcessor).not_to receive(:process)
        
        perform_enqueued_jobs do
          WebhookProcessorJob.perform_later(webhook_event.id)
        end
      end
    end
  end
end
```

3. **Manual testing with webhook forwarding:**
```bash
# Install Stripe CLI for local testing
brew install stripe/stripe-cli/stripe
stripe login

# Forward webhooks to local server
stripe listen --forward-to localhost:3000/webhooks/stripe

# Trigger test webhook
stripe trigger checkout.session.completed

# Check logs for signature verification and job enqueue
```

### Done Checklist
- [ ] WebhooksController handles all 3 providers (Stripe, Twilio, Vapi)
- [ ] Signature verification implemented for each provider
- [ ] Invalid signatures rejected with 401 Unauthorized
- [ ] WebhookEvent model with unique constraint on (provider, event_id)
- [ ] Duplicate events return 200 OK but don't reprocess (idempotent)
- [ ] WebhookProcessorJob enqueued for new events only
- [ ] Job marks event as processing/completed/failed appropriately
- [ ] Retry logic works (exponential backoff, max 3 attempts)
- [ ] Error details logged to Sentry with context
- [ ] All request specs passing (with stubbed signatures)
- [ ] Job specs passing (with mocked processors)
- [ ] Manual testing with Stripe CLI successful

### Gotchas & Pitfalls
- **Request body consumed:** `request.body.read` can only be called once, cache it
- **Signature timing:** Stripe signatures have timestamp, reject if >5 min old (built into gem)
- **Twilio POST data:** Comes as form-encoded, not JSON (use `request.POST.to_h`)
- **Idempotency key:** Use provider's event_id, not our auto-generated UUID
- **Unique constraint race:** find_or_create_by! uses DB-level uniqueness, thread-safe
- **Payload size:** Some webhooks have large payloads (>1MB), ensure DB column supports
- **Retry explosion:** If job fails immediately (e.g., missing ENV var), it'll retry forever - add circuit breaker

### References
- start.md: Section 4.2 (Webhook Handling Playbook), Section 14.5 (Pattern 4: Webhook idempotency)
- BUILD-GUIDE.md: Pattern 4 (Idempotent webhook processing)
- Stripe webhook docs: https://stripe.com/docs/webhooks/signatures
- Twilio webhook security: https://www.twilio.com/docs/usage/webhooks/webhooks-security

---

[Document continues with remaining 124 tickets in same detailed format...]

**SUMMARY OF REMAINING TICKETS:**
Due to response length limits, I've provided detailed breakdowns for the first 6 foundational tickets. The remaining 124 tickets follow the same template structure with:

- Context & Why It Matters
- Implementation Hints (file paths, code patterns, gems)
- Detailed Acceptance Criteria (Gherkin Given/When/Then)
- TDD Approach (specs to write first, test order)
- Done Checklist (quality gates)
- Gotchas & Pitfalls (common mistakes)
- References to start.md and BUILD-GUIDE.md

Each ticket is 2-5 points (1 day or less execution time) and follows the patterns from BUILD-GUIDE.md Section 6 (ticket templates).

---

## APPENDIX: QUICK TICKET NAVIGATION

### Phase 0 - Infrastructure (12 tickets, ~32 points)
- R1-E01-T001 through R1-E01-T012: Rails app, auth, jobs, webhooks, testing, security

### Phase 1 - Trial Experience (15 tickets, ~52 points)
- R1-E02-T001 through R1-E02-T015: Landing page, signup, Vapi/Twilio integration, abuse prevention, mobile UI

### Phase 2 - Mini-Report (12 tickets, ~41 points)
- R1-E03-T001 through R1-E03-T012: Webhook processing, lead extraction, recording player, conversion tracking

### Phase 3 - Stripe & Business (12 tickets, ~36 points)
- R2-E04-T001 through R2-E04-T012: Stripe setup, checkout, webhooks, subscription management

### Phase 4 - Paid Product (14 tickets, ~49 points)
- R2-E05-T001 through R2-E05-T014: Twilio provisioning, inbound routing, lead forms, dashboard

### Phase 4 - Admin Panel (10 tickets, ~35 points)
- R2-E06-T001 through R2-E06-T010: Admin auth, entity search, webhook inspector, cost monitoring

### Phase 4.5 - TCPA Compliance (11 tickets, ~41 points)
- R2-E07-T001 through R2-E07-T011: Timezone detection, quiet hours, DNC, consent logging, velocity caps

### Phase 5 - Speed-to-Lead (11 tickets, ~27 points)
- R3-E08-T001 through R3-E08-T011: Form builder, multi-form support, lead-to-call linking, analytics

### Phase 6 - Analytics (13 tickets, ~37 points)
- R3-E09-T001 through R3-E09-T013: Daily snapshots, dashboard tiles, email reports, MRR tracking

**Total: 130 tickets, ~350 points (30-35 weeks at 10-12 points/week for solo dev with AI assistance)**