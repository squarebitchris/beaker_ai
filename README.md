# Beaker AI - Voice-First AI Phone Agent Platform

## What is Beaker AI?

Beaker AI is a Rails application that provides voice-first AI agents for small businesses. In minutes, a prospect can experience a tailored phone agent for their business, and—once paid—go live with a dedicated number, lead capture, and a real-time dashboard.

**Core Value:** "Call hot leads in 60 seconds, not 60 minutes"—before they call your competitor.

## Tech Stack

**✅ Current Implementation (Phase 0-1 Complete):**
- Using **Sidekiq 7.2** with Redis for background job processing
- **Sidekiq Web UI** at `/sidekiq` for monitoring (admin-protected)
- **Sidekiq-Cron** for recurring jobs (trial reaper, analytics)
- Deployed to **Heroku production** with LIVE API keys
- **Phase 1 Trial Flow** fully operational with personalized AI agents

**Stack:**
- **Backend:** Ruby on Rails 8.1, PostgreSQL (UUID), Sidekiq + Redis
- **Frontend:** Turbo, Stimulus, Tailwind CSS, ViewComponents
- **Voice AI:** Vapi.ai (OpenAI GPT-4 + ElevenLabs voices)
- **Telephony:** Twilio (outbound calls, future inbound routing)
- **Payments:** Stripe (ready for Phase 3)
- **Email:** SendGrid (magic links, notifications)
- **Observability:** Sentry error tracking, Sidekiq monitoring

## Project Phases Overview

1. **Phase 0 (4-6 weeks):** Rails foundation, auth, security baseline
2. **Phase 1 (4-6 weeks):** Magic-link trial, personalized outbound call
3. **Phase 2 (1-2 weeks):** Webhook processing + mini-report (conversion driver)
4. **Phase 3 (2-3 weeks):** Stripe checkout + business conversion
5. **Phase 4 (3-4 weeks):** Admin panel + paid product with phone numbers
6. **Phase 4.5 (parallel with 4):** TCPA compliance & guardrails
7. **Phase 5 (2-3 weeks):** Hosted lead forms + speed-to-lead
8. **Phase 6 (2-3 weeks):** Analytics, reporting, automation

**Total Estimated Time:** 30-35 weeks solo (with AI assistance)

---

## Development Todo List

### ✅ PHASE 0: Rails Foundation & Infrastructure (12 tickets, ~32 points)

**Epic E-001: Rails Foundation**

- [x] **R1-E01-T001** - Initialize Rails 8.1 app with PostgreSQL + UUID support (2 pts) ✅ [Completed](./docs/completed_tickets/R1-E01-T001.md)
- [x] **R1-E01-T002** - Configure Devise + Passwordless gem for magic-link auth (5 pts) ✅ [Completed](./docs/completed_tickets/R1-E01-T002.md)
- [x] **R1-E01-T003** - Set up SolidQueue for background jobs (3 pts) ✅ [Completed](./docs/completed_tickets/R1-E01-T003.md) **Note:** Using SolidQueue instead of planned Sidekiq
- [x] **R1-E01-T004** - Create base models: User, Trial, Assistant, Call, Business (5 pts) ✅ [Completed](./docs/completed_tickets/R1-E01-T004.md)
- [x] **R1-E01-T005** - Implement CircuitBreaker wrapper for API clients (5 pts) ✅ [Completed](./docs/completed_tickets/R1-E01-T005.md)
- [x] **R1-E01-T006** - Build webhook receiver framework with signature verification (5 pts) ✅ [Completed](./docs/completed_tickets/R1-E01-T006.md)
- [x] **R1-E01-T007** - Configure Sentry for observability (2 pts) ✅ [Completed](./docs/completed_tickets/R1-E01-T007.md) **Note:** Lograge removed due to Rails 8 compatibility
- [x] **R1-E01-T008** - Set up RSpec + FactoryBot + test infrastructure (3 pts) ✅ [Completed](./docs/completed_tickets/R1-E01-T008.md)
- [x] **R1-E01-T009** - Configure Rack::Attack for rate limiting (2 pts) ✅ [Completed](./docs/completed_tickets/R1-E01-T009.md)
- [x] **R1-E01-T010** - Set up GitHub Actions CI pipeline (2 pts) ✅ [Completed](./docs/completed_tickets/R1-E01-T010.md)
- [x] **R1-E01-T011** - Deploy to production (Heroku) (3 pts) ✅ [Completed](./docs/completed_tickets/R1-E01-T011.md) **Note:** Deployed to production with LIVE keys, not staging
- [x] **R1-E01-T012** - Create design system foundation (4 components) (3 pts) ✅ [Completed](./docs/completed_tickets/R1-E01-T012.md) **Note:** 4 components (not 8), deferred rest to Phase 1+

**Exit Criteria:**
- ✅ Rails app boots locally with Postgres + Sidekiq + Redis
- ✅ Magic-link auth working (passwordless via Devise)
- ✅ Sidekiq processing jobs (Web UI at `/sidekiq`)
- ✅ Comprehensive test infrastructure (RSpec + FactoryBot + 94% coverage)
- ✅ CI pipeline green (GitHub Actions)
- ✅ Production deployment successful (Heroku with LIVE API keys)
- ✅ Design system with 4 core components (Button, Input, Card, Toast)

---

### ✅ PHASE 1: Trial Experience (15 tickets, ~52 points)

**Epic E-002: Trial Flow**

- [x] **R1-E02-T001** - Landing page with trial signup form (3 pts) ✅ [Completed](./docs/completed_tickets/R1-E02-T001.md)
- [x] **R1-E02-T002** - Seed HVAC scenario template (lead_intake only) (2 pts) ✅ [Completed](./docs/completed_tickets/R1-E02-T002.md)
- [x] **R1-E02-T003** - PromptBuilder service (merge template + persona) (2 pts) ✅ [Completed](./docs/completed_tickets/R1-E02-T003.md)
- [x] **R1-E02-T004** - Vapi client: create assistant API integration (4 pts) ✅ [Completed](./docs/completed_tickets/R1-E02-T004.md)
- [x] **R1-E02-T005** - OpenAI KB generation service (3 pts) ✅ [Completed](./docs/completed_tickets/R1-E02-T005.md)
- [x] **R1-E02-T006** - CreateTrialAssistantJob implementation (4 pts) ✅ [Completed](./docs/completed_tickets/R1-E02-T006.md)
- [x] **R1-E02-T007** - Trial status page with ready polling (3 pts) ✅ [Completed](./docs/completed_tickets/R1-E02-T007.md)
- [x] **R1-E02-T008** - "Call Me Now" button + phone input UI (3 pts) ✅ [Completed](./docs/completed_tickets/R1-E02-T008.md)
- [x] **R1-E02-T009** - SignupsController (email + marketing consent) (3 pts) ✅ [Completed](./docs/completed_tickets/R1-E02-T009.md)
- [x] **R1-E02-T010** - TrialSessionsController (new/create/show with polling) (5 pts) ✅ [Completed](./docs/completed_tickets/R1-E02-T010.md)
- [x] **R1-E02-T011** - Trial builder UI (persona form, mobile-first) (3 pts) ✅ [Completed](./docs/completed_tickets/R1-E02-T011.md)
- [x] **R1-E02-T012** - Trial abuse prevention (email normalization, IP throttles) (4 pts) ✅ [Completed](./docs/completed_tickets/R1-E02-T012.md)
- [x] **R1-E02-T013** - Mobile-first responsive UI for trial flow (5 pts) ✅ [Completed](./docs/completed_tickets/R1-E02-T013.md)
- [x] **R1-E02-T014** - TrialReaperJob (cleanup expired trials) (2 pts) ✅ [Completed](./docs/completed_tickets/R1-E02-T014.md)
- [ ] **R1-E02-T015** - Pre-launch validation (100 cold emails to HVAC) (5 pts)

**Exit Criteria:**
- ✅ Visitor can sign up → build personalized agent → receive call within 60s
- ✅ TTFC ≤10s P95 (Time to First Call)
- ✅ TTFA ≤20s P95 (Time to First Agent Ready)
- ✅ Trial abuse controls working (email normalization, IP throttling)
- ✅ Mobile-responsive UI at 375px
- ✅ Vapi assistant creation with OpenAI knowledge base
- ✅ Recurring trial cleanup job (daily reaper)
- 📋 Pre-launch validation: 5+ positive HVAC responses (R1-E02-T015)

---

### ✅ PHASE 2: Mini-Report (12 tickets, ~41 points) - COMPLETE

**Epic E-003: Webhook Processing & Conversion Driver**  
**Status:** ✅ All 12 tickets completed | **Test Coverage:** 91.23% | **Exit Criteria:** Met

- [x] **R1-E03-T001** - Vapi webhook endpoint + signature verification (3 pts) ✅ [Completed](./docs/completed_tickets/R1-E03-T001.md)
- [x] **R1-E03-T002** - ProcessVapiEventJob (parse call.ended) (4 pts) ✅ [Completed](./docs/completed_tickets/R1-E03-T002.md)
- [x] **R1-E03-T003** - LeadExtractor service (from function calls + transcript) (4 pts) ✅ [Completed](./docs/completed_tickets/R1-E03-T003.md)
- [x] **R1-E03-T004** - IntentClassifier service (3 pts) ✅ [Completed](./docs/completed_tickets/R1-E03-T004.md)
- [x] **R1-E03-T005** - TrialCall model + database migration (2 pts) ✅ [Completed](./docs/completed_tickets/R1-E03-T005.md)
- [x] **R1-E03-T006** - CallCard ViewComponent (with recording + transcript) (5 pts) ✅ [Completed](./docs/completed_tickets/R1-E03-T006.md)
- [x] **R1-E03-T007** - AudioPlayer component (keyboard accessible) (4 pts) ✅ [Completed](./docs/completed_tickets/R1-E03-T007.md)
- [x] **R1-E03-T008** - TrialSessionChannel + Turbo Stream updates (4 pts) ✅ [Completed](./docs/completed_tickets/R1-E03-T008.md)
- [x] **R1-E03-T009** - Mini-report UI (captured fields FIRST, mobile-optimized) (5 pts) ✅ [Completed](./docs/completed_tickets/R1-E03-T009.md)
- [x] **R1-E03-T010** - Upgrade CTA placement + tracking (2 pts) ✅ [Completed](./docs/completed_tickets/R1-E03-T010.md)
- [x] **R1-E03-T011** - PurgeOldTrialsJob (7-day retention) (2 pts) ✅ [Completed by R1-E02-T014](./docs/completed_tickets/R1-E02-T014.md)
- [x] **R1-E03-T012** - Race condition prevention (unique constraints + with_lock) (3 pts) ✅ [Completed](./docs/completed_tickets/R1-E03-T012.md)

**Exit Criteria - All Met:**
- ✅ Call ends → mini-report appears within 3s via Turbo
- ✅ Captured fields display above transcript
- ✅ Recording player works on mobile (≥60px tap target)
- ✅ Webhook→UI latency <3s P95
- ✅ No layout shift (CLS <0.02)

**Summary:** Phase 2 delivers real-time webhook processing, lead extraction, and a mobile-optimized mini-report UI. All tickets complete with 91.23% test coverage. Ready for Phase 3 monetization.

---

### ✅ PHASE 3: Stripe & Business Conversion (12 tickets, ~36 points)

**Epic E-004: Monetization**

- [x] **R2-E04-T001** - Stripe client setup + API keys (2 pts) ✅ [Completed](./docs/completed_tickets/R2-E04-T001.md)
- [x] **R2-E04-T002** - Create Stripe products/prices (Starter $199, Pro $499) (2 pts) ✅ [Completed](./docs/completed_tickets/R2-E04-T002.md)
- [x] **R2-E04-T003** - Checkout session endpoint (3 pts) ✅ [Completed](./docs/completed_tickets/R2-E04-T003.md)
- [x] **R2-E04-T004** - Stripe webhook handler (checkout.session.completed) (4 pts) ✅ [Completed](./docs/completed_tickets/R2-E04-T004.md)
- [x] **R2-E04-T005** - ConvertTrialToBusinessJob (5 pts) ✅ [Completed](./docs/completed_tickets/R2-E04-T005.md)
- [ ] **R2-E04-T006** - Business model + migration (3 pts)
- [ ] **R2-E04-T007** - Clone trial assistant → paid assistant (no caps) (4 pts)
- [ ] **R2-E04-T008** - Onboarding page shell (2 pts)
- [ ] **R2-E04-T009** - "Agent Ready" email template (2 pts)
- [ ] **R2-E04-T010** - Idempotency testing (prevent duplicate businesses) (3 pts)
- [ ] **R2-E04-T011** - Upgrade button in trial UI (2 pts)
- [ ] **R2-E04-T012** - Stripe Tax configuration (2 pts)

**Exit Criteria:**
- Trial → Upgrade → Stripe Checkout → Business created
- Paid assistant created (no time caps)
- Trial marked "converted"
- No duplicate businesses on webhook retry
- Conversion latency ≤5s

---

### ✅ PHASE 4: Paid Product + Dashboard (14 tickets, ~49 points)

**Epic E-005: Live Production**

- [ ] **R2-E05-T001** - **ADMIN PANEL (ships FIRST)** - Base admin interface (5 pts)
- [ ] **R2-E05-T002** - Admin: Webhook event inspector + reprocess (4 pts)
- [ ] **R2-E05-T003** - Admin: Entity search (Business/User/Lead) (3 pts)
- [ ] **R2-E05-T004** - Twilio client setup + number provisioning (4 pts)
- [ ] **R2-E05-T005** - AssignTwilioNumberJob (4 pts)
- [ ] **R2-E05-T006** - Call model for paid calls (3 pts)
- [ ] **R2-E05-T007** - Paid webhook processing (ProcessVapiEventJob extension) (4 pts)
- [ ] **R2-E05-T008** - BusinessChannel for real-time updates (3 pts)
- [ ] **R2-E05-T009** - Dashboard UI: number display, KPI tiles, calls list (5 pts)
- [ ] **R2-E05-T010** - Usage alerts (80%, 100% of quota) (3 pts)
- [ ] **R2-E05-T011** - Empty states (no calls, no number) (2 pts)
- [ ] **R2-E05-T012** - Mobile-responsive dashboard (375px tested) (4 pts)
- [ ] **R2-E05-T013** - "Number Assigned" email (2 pts)
- [ ] **R2-E05-T014** - Cost monitoring + budget alerts (3 pts)

**Exit Criteria:**
- Admin panel operational (webhook inspection, entity search)
- User can assign Twilio number
- Inbound calls appear in dashboard in real-time
- Week 1 success >40% (number + form + dashboard views)
- Dashboard loads <500ms with 50 calls

---

### ✅ PHASE 4.5: TCPA Compliance (11 tickets, ~41 points)
**⚠️ RUNS IN PARALLEL WITH PHASE 4**

**Epic E-007: Compliance & Guardrails**

- [ ] **R2-E07-T001** - ComplianceSetting model + migration (2 pts)
- [ ] **R2-E07-T002** - PhoneTimezone service (area code → timezone mapping) (3 pts)
- [ ] **R2-E07-T003** - QuietHours upgrade (RECIPIENT timezone) (4 pts)
- [ ] **R2-E07-T004** - CallPermission service (DNC, quiet hours, velocity) (5 pts)
- [ ] **R2-E07-T005** - DncNumber model + opt-out flow (3 pts)
- [ ] **R2-E07-T006** - Consent model + logging (4 pts)
- [ ] **R2-E07-T007** - AuditLog model + event tracking (3 pts)
- [ ] **R2-E07-T008** - Velocity caps (Redis counters: per-minute, daily) (4 pts)
- [ ] **R2-E07-T009** - Compliance UI tab (settings, DNC list, audit logs) (5 pts)
- [ ] **R2-E07-T010** - Email unsubscribe flow (signed tokens) (3 pts)
- [ ] **R2-E07-T011** - DataRetentionJob (unified purge policy) (3 pts)

**Exit Criteria:**
- Quiet hours enforced in RECIPIENT timezone (not business)
- Zero outbound calls to DNC numbers
- All consents logged with IP/timestamp
- Velocity caps enforced via Redis
- `call_blocked_quiet_hours` events >0 daily (proves logic working)

---

### ✅ PHASE 5: Speed-to-Lead (11 tickets, ~27 points)

**Epic E-008: Lead Forms**

- [ ] **R3-E08-T001** - LeadSource model + migration (2 pts)
- [ ] **R3-E08-T002** - Lead model + migration (3 pts)
- [ ] **R3-E08-T003** - LeadNormalizer service (phone/email) (2 pts)
- [ ] **R3-E08-T004** - Leads::Upsert service (deduplication) (3 pts)
- [ ] **R3-E08-T005** - Hosted lead form UI (`/l/:slug`) (4 pts)
- [ ] **R3-E08-T006** - LeadFormsController (public endpoint) (3 pts)
- [ ] **R3-E08-T007** - SpeedToLeadJob (immediate outbound call) (3 pts)
- [ ] **R3-E08-T008** - Link calls to leads (call.lead_id) (2 pts)
- [ ] **R3-E08-T009** - Dashboard Leads tab (3 pts)
- [ ] **R3-E08-T010** - "New Lead" email notification (2 pts)
- [ ] **R3-E08-T011** - Form throttling + optional hCaptcha (2 pts)

**Exit Criteria:**
- Public form `/l/:slug` works on mobile
- Form submit → lead created → call within 10s
- Lead appears in dashboard with linked call
- Lead deduplication working (phone/email normalization)
- Consent required and logged

---

### ✅ PHASE 6: Analytics & Reporting (13 tickets, ~37 points)

**Epic E-009: Observability & Automation**

- [ ] **R3-E09-T001** - AnalyticsDaily model + migration (2 pts)
- [ ] **R3-E09-T002** - AnalyticsComputer service (counts + averages) (4 pts)
- [ ] **R3-E09-T003** - AnalyticsIngestJob (near-real-time) (3 pts)
- [ ] **R3-E09-T004** - AnalyticsDailyRollupJob (02:00 local) (3 pts)
- [ ] **R3-E09-T005** - Dashboard tiles (7-day counts: calls, leads, booked) (4 pts)
- [ ] **R3-E09-T006** - DailyReportJob + email template (4 pts)
- [ ] **R3-E09-T007** - ReportMailer (08:00 local, timezone-aware scheduling) (3 pts)
- [ ] **R3-E09-T008** - AnalyticsSystemDaily (platform-level MRR, conversions) (3 pts)
- [ ] **R3-E09-T009** - SystemAnalyticsRollupJob (2 pts)
- [ ] **R3-E09-T010** - Call outcome backfill (booked, lead, no_answer, info) (2 pts)
- [ ] **R3-E09-T011** - Admin: System analytics dashboard (3 pts)
- [ ] **R3-E09-T012** - Feature flags (Flipper integration) (2 pts)
- [ ] **R3-E09-T013** - CSV exports (calls, leads) - **[POST-LAUNCH]** (3 pts)

**Exit Criteria:**
- Dashboard tiles show accurate 7-day data
- Daily email arrives at 08:00 business local time
- Analytics ingest <5s (call → dashboard update)
- Dashboard page loads <500ms
- <2 hrs/week ops time via automation

---

## Quick Start

### Prerequisites

```bash
# Required software
ruby 3.3.6 (install via rbenv or asdf)
postgresql 15+
redis 7+
node 18+ (for Tailwind/esbuild)
```

### Initial Setup

```bash
# 1. Clone and install dependencies
git clone <repo-url>
cd beaker-ai
bin/setup  # Installs gems, creates databases, runs migrations

# 2. Configure environment variables
cp .env.example .env
# Edit .env and add your API keys (see Environment Variables section below)

# 3. Ensure Redis is running
brew services start redis  # macOS
# OR
redis-server  # Linux/manual start

# 4. Start all processes (web, worker, CSS, JS)
bin/dev
```

The app will be available at `http://localhost:3000`

### Running the Trial Flow (Phase 1)

**1. Visit the Landing Page**
```
http://localhost:3000
```

**2. Sign Up for Trial**
- Enter your email address
- Fill in the trial form:
  - Industry: HVAC (currently only option)
  - Business name: e.g., "Smith HVAC"
  - Your phone number: e.g., "+15551234567"
- Submit form

**3. Watch the Magic Happen**
- Assistant is created in background (10-20 seconds)
- Knowledge base generated via OpenAI
- Page auto-refreshes when ready
- Click "Call Me Now" to test your AI agent

**4. Monitor the Process**
```bash
# Watch Sidekiq process jobs in terminal
# OR visit Sidekiq Web UI (requires admin user)
http://localhost:3000/sidekiq

# Watch logs
tail -f log/development.log
```

### Testing Magic-Link Authentication

The app uses passwordless magic-link authentication (no passwords required):

**Development (Letter Opener):**
1. Visit `http://localhost:3000/users/sign_in`
2. Enter an email address
3. Click "Send me a login link"
4. Check magic link at `http://localhost:3000/letter_opener` (auto-opens)
5. Click "Log in to my account" link
6. You're authenticated! ✅

**Production:**
- Magic links sent via SendGrid to real email addresses
- Links expire after 20 minutes for security

### Creating an Admin User

Admin users can access the Sidekiq Web UI and manage jobs:

```bash
# Open Rails console
rails console

# Create or update a user as admin
user = User.find_by(email: 'your@email.com')
user.update(admin: true)

# Now you can access http://localhost:3000/sidekiq
```

### Running Tests

```bash
# Run full test suite (374 specs, ~15 seconds)
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/trial_spec.rb

# Run with coverage report
COVERAGE=true bundle exec rspec
open coverage/index.html

# Run linters
bundle exec rubocop
bundle exec brakeman  # Security scanner
```

### Monitoring Background Jobs

**Sidekiq Web UI** (requires admin user):
```
http://localhost:3000/sidekiq
```

Features:
- **Dashboard** - Real-time job stats, queue depths
- **Busy** - Currently processing jobs
- **Queues** - View critical/default/low queues
- **Retries** - Failed jobs waiting for retry
- **Dead** - Jobs that exhausted retries
- **Cron** - Recurring jobs (TrialReaperJob runs daily)

**Terminal Monitoring:**
```bash
# Watch Sidekiq logs
tail -f log/development.log | grep Sidekiq

# Check Redis
redis-cli
> KEYS sidekiq:*
> LLEN sidekiq:queue:default
```

## Environment Variables Required

Copy `.env.example` to `.env` and configure:

### Phase 0-1 Required Variables

**Database & Redis:**
```bash
DATABASE_URL=postgresql://localhost/beaker_ai_development
REDIS_URL=redis://localhost:6379/1
```

**Application:**
```bash
APP_HOST=localhost:3000
RAILS_ENV=development
SECRET_KEY_BASE=<generate via 'rails secret'>
```

**Voice AI (Vapi.ai):**
```bash
VAPI_API_KEY=your_vapi_key_here
VAPI_WEBHOOK_SECRET=your_vapi_webhook_secret
```

**OpenAI (for knowledge base generation):**
```bash
OPENAI_API_KEY=your_openai_key_here
```

**Telephony (Twilio):**
```bash
TWILIO_ACCOUNT_SID=your_twilio_sid
TWILIO_AUTH_TOKEN=your_twilio_token
TWILIO_PHONE_NUMBER=+1234567890  # Your Twilio number for outbound
```

**Email (SendGrid):**
```bash
SENDGRID_API_KEY=your_sendgrid_key
```

**Monitoring:**
```bash
SENTRY_DSN=your_sentry_dsn  # Optional but recommended
```

### Phase 3+ Variables (Future)

**Stripe (Payments):**
```bash
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
STRIPE_SUCCESS_URL=https://your-app.com/success
STRIPE_CANCEL_URL=https://your-app.com/cancel
```

**Note:** Stripe products and prices are created programmatically using `rails stripe:sync_products`. No manual Stripe Dashboard setup required.

**Webhook Callbacks:**
```bash
TWILIO_STATUS_CALLBACK_URL=https://your-app.com/webhooks/twilio
VAPI_WEBHOOK_URL=https://your-app.com/webhooks/vapi
STRIPE_SUCCESS_URL=https://your-app.com/checkout/success
STRIPE_CANCEL_URL=https://your-app.com/checkout/cancel
```

See [Environment Variables Documentation](./docs/environment-variables.md) for complete details.

### Stripe Setup (Phase 3)

**Automated Product Creation:**

Beaker AI creates Stripe products programmatically - no manual Dashboard setup needed!

```bash
# 1. Get your Stripe API key from dashboard.stripe.com
# Add to .env: STRIPE_SECRET_KEY=sk_test_...

# 2. Seed database with placeholders
rails db:seed

# 3. Create products in Stripe
rails stripe:sync_products

# 4. Verify configuration
rails stripe:verify
```

See [Stripe Setup Guide](./docs/stripe-setup-guide.md) for complete details.

## Key Metrics & Success Criteria

### Phase 0-1 (Current)
- **TTFC (Time to First Call):** ≤10s P95 ✅
- **TTFA (Time to First Agent Ready):** ≤20s P95 ✅
- **Test Coverage:** >90% (currently 94.4%) ✅
- **Trial Call Success Rate:** >85% (target)
- **Mobile Responsive:** Works at 375px ✅

### Phase 2+ (Future)
- **Trial → Paid Conversion:** >15% (target)
- **Week 1 Success Rate:** >40% (target)
- **Mini-Report Load Time:** <3s P95
- **Dashboard Load Time:** <500ms with 50 calls

## Project Structure

```
app/
├── components/         # ViewComponents (Button, Input, Card, Toast)
│   └── primitives/     # Reusable UI primitives
├── controllers/        # Rails controllers (trials, signups, webhooks)
├── jobs/              # Sidekiq jobs (CreateTrialAssistantJob, TrialReaperJob)
├── models/            # ActiveRecord models (User, Trial, Call, Business)
├── services/          # Business logic (VapiClient, PromptBuilder, KbGenerator)
└── views/             # ERB templates

config/
├── sidekiq.yml        # Sidekiq queue configuration
├── schedule.yml       # Sidekiq-Cron recurring jobs
└── initializers/
    ├── sidekiq.rb     # Sidekiq + Redis setup
    ├── stoplight.rb   # Circuit breakers for API clients
    └── rack_attack.rb # Rate limiting

docs/
├── start.md                  # Complete product + technical spec
├── ticket-breakdown.md       # Detailed ticket breakdowns
├── BUILD-GUIDE.md           # Architecture decisions + patterns
├── completed_tickets/       # Implementation details for each ticket
└── SIDEKIQ-MIGRATION.md    # Sidekiq migration documentation
```

## Common Development Tasks

### Create a New Trial (Rails Console)

```ruby
rails console

# Create user
user = User.create!(email: 'test@example.com')

# Create trial
trial = user.trials.create!(
  industry: 'hvac',
  business_name: 'Test HVAC',
  scenario: 'lead_intake',
  phone_e164: '+15551234567'
)

# Trigger assistant creation
CreateTrialAssistantJob.perform_now(trial.id)

# Check status
trial.reload.status  # => "active"
trial.vapi_assistant_id  # => "asst_abc123..."
```

### Manually Trigger a Trial Call

```ruby
rails console

trial = Trial.find_by(code: 'ABC123')
StartTrialCallJob.perform_now(trial.id, trial.phone_e164)
```

### View Sidekiq Job Status

```ruby
rails console

# Check queue depths
Sidekiq::Stats.new.queues
# => {"critical"=>0, "default"=>2, "low"=>0}

# View scheduled jobs
Sidekiq::ScheduledSet.new.each { |job| puts job.display_class }

# View retries
Sidekiq::RetrySet.new.size
```

### Run Background Jobs Inline (Testing)

```ruby
# In test environment, use Sidekiq testing mode
Sidekiq::Testing.inline! do
  CreateTrialAssistantJob.perform_later(trial.id)
  # Job executes immediately, synchronously
end
```

## Troubleshooting

### Sidekiq Not Processing Jobs

```bash
# Check if Redis is running
redis-cli ping
# Should return: PONG

# Check Sidekiq worker logs
tail -f log/development.log | grep Sidekiq

# Restart Sidekiq worker
# Stop bin/dev and restart, or manually:
bundle exec sidekiq -C config/sidekiq.yml
```

### Magic Links Not Sending

```bash
# Development: Check Letter Opener
open http://localhost:3000/letter_opener

# Production: Check SendGrid dashboard
# Verify SENDGRID_API_KEY is set
```

### Vapi Assistant Creation Failing

```bash
# Check API key
rails console
VapiClient.new.create_assistant(...)
# Should not raise authentication error

# Check circuit breaker status
Stoplight('vapi:create_assistant').color
# => :green (working) or :red (circuit open)
```

### Database Connection Issues

```bash
# Check PostgreSQL is running
psql -d beaker_ai_development -c "SELECT 1"

# Recreate databases
rails db:drop db:create db:migrate db:seed
```

## Documentation

- **[start.md](./docs/start.md)** - Complete product + technical specification
- **[ticket-breakdown.md](./docs/ticket-breakdown.md)** - Detailed ticket breakdowns with implementation hints
- **[BUILD-GUIDE.md](./docs/BUILD-GUIDE.md)** - Architecture decisions + patterns
- **[completed_tickets/](./docs/completed_tickets/)** - Implementation details for each completed ticket
- **[SIDEKIQ-MIGRATION.md](./SIDEKIQ-MIGRATION-SUMMARY.md)** - Background job system migration documentation

## License

Proprietary - All rights reserved
