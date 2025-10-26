# Beaker AI — Build Execution Guide

**Doc Owner:** Engineering Leadership  
**Audience:** Mid-level engineers creating detailed tickets  
**Prerequisite:** Read `start.md` thoroughly before using this guide  
**Last Updated:** October 25, 2025

---

## 1. Purpose & How to Use This Document

### What This Document Is

This is your **execution playbook** for turning `start.md`'s strategic vision into shippable tickets. It bridges the gap between "what we're building" (start.md) and "how to break it down for a mid-level team."

### Relationship to start.md

- **start.md** = Product vision, technical architecture, phase requirements, code patterns
- **BUILD-GUIDE.md (this doc)** = Execution strategy, ticket structure, TDD workflows, priority enforcement

**Use them together:**
1. Read start.md Sections 1-9 for product context
2. Read this guide for execution approach
3. Reference start.md sections when creating tickets
4. Use this guide's templates for ticket format

### Target Audience

**Mid-level Rails engineers** (2-4 years experience) who will:
- Break epics into granular tickets (2-5pt each)
- Write detailed acceptance criteria and test plans
- Guide junior engineers through implementation
- Enforce quality gates (coverage, performance, accessibility)

**Not for:** Junior devs executing tickets (those get even more detail), or senior devs who can work from start.md directly.

### Document Navigation

- **Section 2:** Tech decisions (locked, no debate)
- **Section 3:** Build philosophy (how to think about tickets)
- **Section 4:** Critical priorities (what cannot slip)
- **Section 5:** Epic strategies (breakdown guidance per phase)
- **Section 6:** Ticket templates (format examples)
- **Section 7:** Testing patterns (TDD workflows)
- **Section 8:** Handoff checklist (pre-work)

---

## 2. Locked Technical Decisions

The following decisions are **final** to eliminate ambiguity during ticket creation. Do not debate these; implement as specified.

### Decision 1: Email Provider = SendGrid

**Rationale:** Mature API, good Rails integration, transactional + marketing support

**Implementation Notes:**
```ruby
# Gemfile
gem 'sendgrid-ruby'

# config/environments/production.rb
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: 'smtp.sendgrid.net',
  port: 587,
  authentication: :plain,
  user_name: 'apikey',
  password: ENV['SENDGRID_API_KEY']
}

# Development: Use letter_opener gem (already in start.md Phase 0)
```

**Affects Tickets:** Phase 1 magic links, Phase 3 onboarding emails, Phase 6 daily reports

**Testing Approach:** Use `letter_opener` in dev, stub `ActionMailer::Base.deliveries` in specs, SendGrid test mode in staging

---

### Decision 2: Admin Panel = Custom Rails Views (No Gem)

**Rationale:** Full control over UX, teaches patterns, avoids gem constraints

**Implementation Notes:**
```ruby
# app/controllers/admin/base_controller.rb
class Admin::BaseController < ApplicationController
  before_action :require_admin
  layout 'admin'
  
  private
  def require_admin
    redirect_to root_path unless current_user&.admin?
  end
end

# All admin controllers inherit from this
class Admin::WebhooksController < Admin::BaseController
  # ...
end
```

**Affects Tickets:** P4-01 (admin panel), Phase 6 analytics admin views

**UI Framework:** Stimulus controllers + Tailwind + ViewComponents (no ActiveAdmin, Avo, Trestle)

**Estimate Impact:** +3-5pts per admin ticket vs gem-based approach (acceptable for control/learning)

---

### Decision 3: Monitoring = Sentry Only

**Rationale:** Sufficient for MVP, avoid multi-tool complexity, cost-effective

**Implementation Notes:**
```ruby
# Gemfile
gem 'sentry-ruby'
gem 'sentry-rails'
gem 'sentry-sidekiq'

# config/initializers/sentry.rb
Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.traces_sample_rate = 0.2
  config.profiles_sample_rate = 0.2
end
```

**Alert Configuration:** Use Sentry's built-in alerting (see Section 4.4 for tripwire setup)

**No Datadog, No New Relic, No Prometheus** until post-MVP (>100 customers)

---

### Decision 4: Design System = ShadCN-Inspired Tokens + ViewComponents

**Rationale:** ShadCN's token approach is excellent, but we're Rails not React

**Implementation Approach:**
1. Extract ShadCN CSS variables → `app/assets/stylesheets/tokens.css`
2. Map to Tailwind config → `tailwind.config.js`
3. Build ViewComponents using tokens → `app/components/primitives/*`
4. **NOT** using ShadCN React components (we're server-rendered Rails)

**Key Pattern:**
```css
/* tokens.css - ShadCN inspired */
:root {
  --background: 0 0% 100%;
  --foreground: 222.2 84% 4.9%;
  --primary: 221.2 83.2% 53.3%;
  /* ... rest from ShadCN palette */
}

/* Tailwind maps these */
@layer base {
  * { border-color: hsl(var(--border)); }
}
```

**Reference:** See start.md T0.15-T0.16 for complete token system

**Affects Tickets:** T0-003 (design system), all UI tickets (use primitives not raw Tailwind)

---

### Decision 5: Feature Flags = Flipper (In-App, Redis-Backed)

**Rationale:** Simple, no external service, sufficient for A/B tests

**Implementation Notes:**
```ruby
# Gemfile
gem 'flipper'
gem 'flipper-active_record'  # Store flags in DB
gem 'flipper-ui'              # Admin interface

# config/initializers/flipper.rb
Flipper.configure do |config|
  config.default { Flipper.new(Flipper::Adapters::ActiveRecord.new) }
end

# Usage in code
if Flipper.enabled?(:speed_to_lead, business)
  # Feature active for this business
end
```

**No LaunchDarkly, No Split.io** (overkill for MVP)

**Flags to Plan For:**
- `enable_hcaptcha` (trial abuse)
- `speed_to_lead_enabled` (Phase 5 killswitch)
- `vapi_degraded` (circuit breaker status page)
- `analytics_enabled` (Phase 6 rollout)

---

## 3. Build Philosophy for Mid-Level Teams

### Ticket Granularity Principle

**Target:** 2-5pt tickets with single responsibility

**Why:** Mid-level engineers need clear scope boundaries. Juniors executing these tickets need even clearer direction.

**Granularity Rules:**

| Points | Scope | Example | Ideal For |
|--------|-------|---------|-----------|
| 1-2pt | Single file/class, clear pattern | Add validation to model, simple controller action | Junior dev
| 3-5pt | Feature area, light integration | Job with external API + tests, UI component with variants | Mid-level dev |
| 8pt | Multi-file feature with coordination | Controller + UI + job + real-time updates | Senior dev or pair |
| 13pt+ | **TOO BIG** - split into smaller tickets | Epic-level work | Never use |

**Anti-Pattern (from analyses):**
> "Implement webhook processing (15pts)" ❌ Too vague, too big

**Better:**
> "Process Vapi call.ended webhook with idempotency (5pts)" ✅  
> "Create TrialCall record from webhook data (3pts)" ✅  
> "Broadcast Turbo Stream update on call completion (3pts)" ✅

### TDD Workflow (Non-Negotiable)

Every ticket follows this sequence:

```
1. Write failing spec (RED)
   - Request spec for controllers
   - Job spec for background work
   - Model spec for validations

2. Implement to pass spec (GREEN)
   - Minimal code to pass tests
   - No gold-plating

3. Refactor (REFACTOR)
   - Extract services, clean up
   - Ensure Bullet clean (N+1 check)

4. System test (INTEGRATION)
   - Only for critical user flows
   - Last step, not first
```

**Enforcement:** Code review blocks merge if tests written after implementation.

### Code Patterns from start.md (Critical)

Mid-level devs MUST internalize these 5 patterns:

#### Pattern 1: Race Condition Prevention (Database-First)
```ruby
# ✅ GOOD: Atomic upsert (database constraint wins)
Lead.create_with(name: name).find_or_create_by!(business_id: bid, phone: phone)

# ✅ OK: Pessimistic lock (complex state transitions only)
trial_session.with_lock do
  trial_session.increment!(:calls_used)
end

# ❌ BAD: Race condition
lead = Lead.find_or_initialize_by(business_id: bid, phone: phone)
lead.update!(name: name)  # Another process might create it
```

**Reference:** start.md Critical Implementation Notes #2

#### Pattern 2: Webhook Idempotency
```ruby
# Controller (fast ACK)
event = WebhookEvent.create!(provider: 'vapi', event_id: payload['id'], raw: payload)
ProcessWebhookJob.perform_later(event.id)
head :ok
rescue ActiveRecord::RecordNotUnique
  head :ok  # Already processed

# Job (idempotent processing)
def perform(webhook_event_id)
  event = WebhookEvent.find(webhook_event_id)
  return if event.status == 'processed'
  
  event.with_lock do
    # Process event logic
    event.update!(status: 'processed')
  end
end
```

**Reference:** start.md Section 14.5 (Quick Reference Patterns)

#### Pattern 3: Circuit Breakers (Every External API)
```ruby
# app/services/vapi_client.rb
def create_assistant(...)
  circuit_breaker.run do
    @http.post("#{BASE}/assistant", json: body)
  end
rescue Stoplight::Error::RedLight
  Sentry.capture_message("Vapi circuit open")
  raise VapiUnavailableError, "Voice AI temporarily unavailable"
end

private
def circuit_breaker
  @circuit_breaker ||= Stoplight(:vapi)
    .with_threshold(5)         # Open after 5 failures
    .with_timeout(60)          # Stay open 60s
    .with_cool_off_time(30)    # Half-open after 30s
end
```

**Reference:** start.md T0.14 and Critical Implementation Notes #3

#### Pattern 4: TCPA Compliance (Recipient Timezone)
```ruby
# ❌ WRONG: $500-$1,500 per call violation
QuietHours.check(business.timezone)

# ✅ RIGHT: Derive from recipient phone
recipient_tz = PhoneTimezone.lookup(lead.phone)  # Area code → timezone
QuietHours.check(recipient_tz)
```

**Reference:** start.md Critical Implementation Notes #4

#### Pattern 5: Performance (N+1 Prevention)
```ruby
# ❌ BAD: N+1 query
businesses.each { |b| b.calls.count }

# ✅ GOOD: Eager load + counter cache
businesses.includes(:calls).each { |b| b.calls.size }

# Even better: Use counter cache column
add_column :businesses, :calls_count, :integer, default: 0
```

**Reference:** start.md Section 12 (Test Strategy)

### When to Ask vs Decide

**Mid-level engineers should decide:**
- File/class naming conventions (follow Rails conventions)
- Local refactoring (extract methods, services)
- Test setup (factories, fixtures, VCR cassettes)
- Minor UI variations (button colors, spacing)

**Mid-level engineers should ask:**
- Changes to data model (new columns, tables, indexes)
- External API integration approach (which endpoint to use)
- Performance tradeoffs (caching strategy, query optimization)
- Security implications (auth changes, PII handling)
- Deviations from start.md patterns

**Escalation Rule:** If ticket ambiguity blocks >2 hours, ask. Don't guess on critical paths.

### Quality Gates (Enforce Before Merge)

Every PR must pass:

```markdown
## PR Checklist (Copy to GitHub PR Template)

### Functionality
- [ ] Acceptance criteria met (all Given/When/Then passing)
- [ ] Manual testing on dev server (not just specs)
- [ ] Mobile tested at 375px (Chrome DevTools)

### Tests
- [ ] RSpec specs written BEFORE implementation (TDD)
- [ ] Coverage: Request specs for controllers, job specs for background work
- [ ] VCR cassettes for external APIs (Vapi, Twilio, Stripe)
- [ ] Idempotency tested (duplicate webhooks/jobs safe)
- [ ] Performance: Bullet clean (no N+1 queries)

### Code Quality
- [ ] Follows start.md patterns (see Section 3 of BUILD-GUIDE)
- [ ] No raw Tailwind in views (use ViewComponents)
- [ ] Error handling with specific exceptions (not rescue StandardError)
- [ ] PII redacted from logs (emails/phones masked)

### Accessibility (UI tickets only)
- [ ] Keyboard navigable (tab order logical)
- [ ] Focus visible (2px ring on interactive elements)
- [ ] Touch targets ≥44px (mobile)
- [ ] Semantic HTML (buttons not divs, proper headings)

### Security
- [ ] CSRF enabled (except webhooks)
- [ ] SQL injection safe (use ActiveRecord, no raw SQL)
- [ ] Secrets in ENV not hardcoded
- [ ] Webhook signatures verified

### Documentation
- [ ] Complex logic has inline comments
- [ ] start.md section referenced in ticket/code
- [ ] Gotchas documented for next engineer
```

---

## 4. Critical Execution Priorities

These are **non-negotiable sequencing requirements** from start.md. Ticket creation must enforce these constraints.

### 4.1 Pre-Launch Validation Gate (Week 0-2, BLOCKS Phase 1)

**What:** 100 HVAC cold emails + manual demos BEFORE coding Phase 1

**Why:** Building a trial nobody wants wastes 8 weeks. Validate demand first.

**Exit Criteria (start.md Section 10.6):**
- 5+ positive responses from HVAC prospects
- 1+ completed manual demo with real prospect
- Positioning validated (speed-to-lead angle resonates)

**Decision Tree:**

```
IF Strong Signal (10+ responses, 3+ "I'd pay for this"):
  → Proceed with Phase 1 as planned
  → Allocate $500 to paid acquisition
  → Create tickets for E-001, E-002, E-003

IF Minimum Signal (5-9 responses, 1 demo):
  → Iterate messaging (test after-hours angle vs speed)
  → Expand to 200 more emails with new template
  → Reassess after 2 more weeks

IF Weak Signal (<5 responses, 0 demos):
  → STOP BUILDING - Pivot required
  → Try different ICP (gym instead of HVAC)
  → Or different pain point (appointment booking)
  → Do NOT create Phase 1 tickets until pivot validated
```

**Ticket Creation Impact:**

Create **Sprint 0 (Validation)** with these non-code activities:
- V-001: HVAC prospect scraping (200 contractors) - 0pts, 1 day
- V-002: Email campaign execution (100 emails) - 0pts, 5 days
- V-003: Manual demo with prospects (3+ attempts) - 0pts, 3 days
- V-GATE: Decision point (Proceed/Pivot/Iterate) - BLOCKS Phase 1

**Only after V-GATE passes** do you create tickets for E-001 (Foundations).

---

### 4.2 Mini-Report as Sacred (Phase 2)

**What:** The mini-report screen is THE conversion driver (80% of upgrades). It gets dedicated sprint attention.

**Why:** start.md Section 2 (Phase 2) emphasizes: "Prioritize mini-report perfection over all other Phase 2 UI work."

**Requirements (Non-Negotiable):**
- Captured fields displayed FIRST (above transcript)
- Recording play button ≥60px tap target on mobile
- Loads in <3s P95 after webhook received
- Works flawlessly at 375px width
- Real-time appearance (Turbo Stream, no refresh)
- Intent badge visible (lead_intake/scheduling/info)

**Sprint Structure:**

```
Sprint 6 (After trial flow works):
ONLY mini-report work - no other features this sprint

Tickets:
- MR-01: Mobile layout (fields above fold, 60px play button) - 5pts
- MR-02: Load performance (<3s P95, skeleton states) - 3pts
- MR-03: Recording player accessibility (keyboard controls) - 3pts
- MR-04: Conversion tracking (CTA click rate) - 2pts

Total: 13pts, 1 week, 100% focus
```

**Enforcement:** Do not create tickets for other Phase 2 features until mini-report sprint ships.

**A/B Test Readiness:** Build with variant capability (captured fields top vs bottom) for future testing (start.md Section 13.7 #2).

---

### 4.3 Admin Panel Ships FIRST (Phase 4)

**What:** P4-01 (Admin Panel) is the FIRST ticket in Phase 4, before paid product features

**Why:** First conversion failure or webhook issue requires immediate diagnosis. Without admin tools, debugging takes hours via SSH.

**Sprint Structure:**

```
Sprint 14 (Phase 4 Start):
Track A: Admin Panel (PRIORITY)
- P4-01a: Admin auth + base layout - 3pts
- P4-01b: Webhook event inspector - 5pts
- P4-01c: Event reprocessing - 3pts
- P4-01d: Entity search - 5pts
Total: 16pts

Track B: (NOTHING - admin only this sprint)

Sprint 15 (Paid Features Start):
Track A: Twilio number provisioning - 5pts
Track B: Compliance models (can start after admin ships)
```

**Enforcement:** Do not create tickets for Twilio integration (P4-02+) until P4-01 is merged.

**Admin Capabilities Required:**
1. Inspect webhook payloads (raw JSON)
2. Reprocess failed events (with idempotency warning)
3. Search businesses/users/leads by email/phone/ID
4. View Sidekiq queue status
5. Override trial expiration (support requests)

**Reference:** start.md Section "Why Admin Ships First"

---

### 4.4 Parallel Compliance (Phase 4.5 with Phase 4)

**What:** Phase 4.5 (Compliance) work starts SAME TIME as Phase 4 paid features, not after

**Why:** TCPA liability begins with first paid outbound call. Cannot launch paid without compliance.

**Sprint Timeline:**

```
Sprint 14: Admin panel (required for debugging)
Sprint 15: Track A = Twilio numbers | Track B = Compliance models START
Sprint 16: Track A = Dashboard UI | Track B = Quiet hours enforcement
Sprint 17: Track A = Inbound handling | Track B = DNC + velocity caps
Sprint 18: Track A = Polish | Track B = Compliance testing

Both tracks ship simultaneously by end of Sprint 18
```

**Enforcement:** Create Phase 4.5 tickets BEFORE Sprint 15 begins. Assign parallel tracks to different engineers if possible.

**Critical Compliance Tickets (Cannot Skip):**
- Consent logging with IP/timestamp (start.md Section 8)
- Quiet hours in RECIPIENT timezone (not business) - $500/call penalty
- DNC list integration (block before every outbound)
- Velocity caps (Redis counters)
- Audit trail for blocked calls

**Reference:** start.md Critical Implementation Notes #4 and Phase 4.5 section

---

### 4.5 Operational Readiness (Before Stage 2 Launch)

**What:** Tripwire alerts, runbooks, and monitoring configured BEFORE first paid customer

**Why:** Solo founder needs <2hrs/week ops time. Automation must work from day 1.

**Tickets to Create (Often Missing from Analyses):**

```
OPS-01: Configure Sentry Alert Rules (11 tripwires) - 3pts
  - Trial cost P90 >$0.70 (investigate), >$1.00 (critical)
  - Circuit breaker trips >3/24h
  - Webhook backlog >100 events
  - call_blocked_quiet_hours == 0 for 24h (bypass bug)
  - See start.md Section 8.7 for complete list

OPS-02: Document Runbooks RB-01 through RB-05 - 3pts
  - Payment processing down
  - Trial calls failing
  - Webhook backlog
  - Trial abuse spike
  - TCPA quiet hours violation

OPS-03: Test Runbooks on Staging - 5pts
  - Simulate each failure scenario
  - Verify recovery procedures
  - Time each runbook (target: <30min resolution)
```

**Schedule:** Sprint 13 (before R2 launch) or Sprint 18 (before R3 launch)

**Reference:** start.md Section 8.6-8.7

---

## 5. Epic-Level Execution Strategy

### E-001: Foundations (Phase 0) — 1 Sprint, 32pts (Actually Completed)

**✅ COMPLETED:** Phase 0 used Sidekiq for background job processing with Redis, following industry best practices for production reliability.

**Objective:** Production-grade Rails skeleton with auth, jobs, security, and component library.

**Actual Ticket Breakdown (12 tickets, 32pts):**

```
T0-01: Rails scaffold + essential gems (2pts) ✅
  - rails new Rails 8.1, Postgres UUIDs, Tailwind, Devise
  - RSpec configured with FactoryBot/VCR/WebMock
  - bin/setup provisions DB, seeds run
  
T0-02: Magic-link authentication (Devise passwordless) (5pts) ✅
  - User model with devise modules
  - Magic link email flow
  - Tests: Auth request spec, factory

T0-03: Sidekiq for background jobs (3pts) ✅ **Sidekiq with Redis**
  - Sidekiq 7.2+ with sidekiq-cron for recurring jobs
  - Sidekiq Web UI at `/sidekiq` (admin-protected)
  - config/sidekiq.yml with critical/default/low queues
  - Redis for job queuing and Rack::Attack
  - Tests: Job specs, queue processing

T0-04: Core domain models (5pts) ✅
  - User, Trial, Call, Business with UUID PKs
  - Associations, validations, factories
  - Tests: Model specs, Bullet clean

T0-05: Circuit breakers (Stoplight) (5pts) ✅
  - VapiClient, TwilioClient, StripeClient with Stoplight
  - Timeout configuration (5s/10s per start.md)
  - Tests: Circuit breaker specs, timeout handling

T0-06: Webhook framework + idempotency (5pts) ✅
  - WebhookEvent model with unique (provider, event_id)
  - Base webhook controller pattern
  - Signature verification for all 3 providers
  - Tests: Idempotency verification

T0-07: Sentry observability (2pts) ✅
  - Sentry error tracking  
  - Tests: Error capture verification

T0-08: RSpec + test infrastructure (3pts) ✅
  - SimpleCov, parallel tests, VCR
  - Test helpers, factories
  - 94%+ coverage

T0-09: Rack::Attack rate limiting (2pts) ✅
  - Rate limiting, throttles
  - Tests: Throttle specs

T0-10: GitHub Actions CI (2pts) ✅
  - CI pipeline with Postgres/Redis
  - Security scanning (Brakeman, bundler-audit)

T0-11: Deploy to production (Heroku) (3pts) ✅
  - Heroku deployment with API keys
  - Worker dyno for Sidekiq
  - Heroku Redis addon for job queue
  - Production database configuration

T0-12: Design system (4 ViewComponents) (3pts) ✅
  - tokens.css with ShadCN-inspired variables
  - Tailwind config mapping
  - Primitives: Button, Input, Card, Toast
  - ViewComponent::Preview for each (visual gallery)
  - Theme switching (light/dark)
  - Tests: Component specs, accessibility
```

**Key Implementation:**

1. **Sidekiq for Jobs:**
   - Production-ready job processing with Redis
   - Sidekiq Web UI for monitoring at `/sidekiq`
   - sidekiq-cron for recurring jobs (trial reaper)
   - Better production stability and ecosystem

2. **Redis Configuration:**
   - REDIS_URL for both Sidekiq and Rack::Attack
   - Heroku Redis mini addon (~$3/month)
   - SSL configuration for Heroku Redis

**TDD Workflow:**
- Week 1, Days 1-2: T0-01 (scaffold, no TDD needed)
- Week 1, Days 3-4: T0-02, T0-03 (write specs first, VCR cassettes)
- Week 1, Day 5: T0-04, T0-05 (request specs for security)
- Week 2, Days 1-3: T0-06-T0-12 (component specs before implementations)

**Common Pitfalls:**
- Skipping ViewComponent::Preview (visual QA critical for frontend)
- Not testing circuit breaker transitions (open/half-open/closed)
- Hardcoding secrets instead of ENV vars
- Missing indexes on webhook_events (provider, event_id)
- Not configuring Sidekiq SSL parameters for Heroku Redis

**Reference Sections:** start.md Phase 0 (T0.01-T0.17), Section 10 (Engineering Principles)

**Estimated Duration:** 2 weeks (actual completion time for Phase 0)

---

### E-002: Trial Flow (Phase 1) — 2 Sprints, 28pts

**Objective:** Prospect signs up via magic link, builds personalized agent, receives call in <60s with abuse controls.

**Recommended Ticket Breakdown (10 tickets):**

```
SPRINT 1 (Trial Infrastructure - 13pts):
T1-01: Trial models + migrations (TrialSession, ScenarioTemplate) (3pts)
T1-02: Seed HVAC scenario template (lead_intake only) (2pts)
T1-03: PromptBuilder service (merge template + persona) (2pts)
T1-04: CreateTrialAssistantJob (calls Vapi, sets assistant_id) (3pts)
T1-05: StartTrialCallJob (outbound with caps/quiet hours) (3pts)

SPRINT 2 (Trial UI + Abuse - 15pts):
T1-06: Signup controller (email + marketing consent) (3pts)
T1-07: TrialSessionsController (new/create/show with polling) (5pts)
T1-08: Trial builder UI (persona form, mobile-first) (3pts)
T1-09: Email normalization + IP throttling (Rack::Attack) (3pts)
T1-10: TrialReaperJob (expire old assistants) (2pts)
```

**TDD Workflow:**
- **Start with jobs:** Write job specs first (easier to test in isolation)
  - T1-04: CreateTrialAssistantJob spec → implementation → VCR cassette
  - T1-05: StartTrialCallJob spec → implementation → cap/quota tests
- **Then controllers:** Request specs define API contract
  - T1-06, T1-07: Request specs → controller implementation
- **Finally UI:** System specs for E2E flow
  - T1-08: Component specs → Stimulus controllers → system spec

**Common Pitfalls:**
- Not using `with_lock` in StartTrialCallJob (race on calls_used increment)
- Forgetting to normalize emails before uniqueness check
- Missing VCR cassettes for Vapi (specs fail in CI)
- Skipping quiet hours tests (TCPA liability)
- Not testing trial expiration edge cases

**Mobile Requirements (Every UI Ticket):**
- Test at 375px width (iPhone SE)
- Touch targets ≥44px height/width
- No horizontal scroll at any breakpoint
- Forms: inputs ≥48px height, text ≥16px (prevents zoom)

**Reference Sections:** start.md Phase 1, Section 5 (Trial Flow), Section 12 (Testing Strategy)

**Estimated Duration:** 2 sprints (4 weeks for mid-level team)

---

### E-003: Mini-Report (Phase 2) — 2 Sprints, 23pts

**Objective:** Real-time mini-report appears after call with recording, transcript, captured fields.

**Recommended Ticket Breakdown (8 tickets):**

```
SPRINT 3 (Webhook Processing - 13pts):
T2-01: Webhook models (WebhookEvent, TrialCall) + migrations (3pts)
T2-02: Vapi webhook controller (signature verify, fast ACK) (3pts)
T2-03: ProcessVapiEventJob (parse, upsert TrialCall) (5pts)
T2-04: LeadExtractor + IntentClassifier services (3pts)

SPRINT 4 (Mini-Report UI - DEDICATED - 13pts):
T2-05: TrialSessionChannel (ActionCable for Turbo Streams) (2pts)
T2-06: CallCard ViewComponent (recording, transcript, captured) (5pts)
T2-07: Mini-report mobile optimization (<3s load, 60px tap) (3pts)
T2-08: Conversion tracking (CTA click monitoring) (2pts)
T2-09: PurgeOldTrialsJob (7-day retention) (2pts)
```

**TDD Workflow:**
- **Webhook path (critical):**
  1. Write request spec for `POST /webhooks/vapi` (signature, idempotency)
  2. Write job spec for ProcessVapiEventJob (upsert, broadcast)
  3. Test concurrent processing (2 threads, same event_id)
  4. Implement controller → job → services
  
- **UI path:**
  1. Write component spec for CallCard (all variants)
  2. Write system spec for Turbo Stream prepend
  3. Implement component → Stimulus controllers
  4. Measure performance (LCP <2s, CLS <0.02)

**Common Pitfalls:**
- Missing `rescue ActiveRecord::RecordNotUnique` in ProcessVapiEventJob
- Not testing webhook signature verification (security hole)
- Transcript display causes layout shift (CLS >0.1) - use skeleton
- Audio player doesn't work on iOS (use native `<audio>` element)
- Forgetting to update calls_used counter after webhook
- N+1 query loading trial_calls for stats (use counter cache)

**Performance Budget (Enforce in Tests):**
```ruby
# spec/system/mini_report_spec.rb
it "loads mini-report in <3s after webhook" do
  trial = create(:trial_session)
  
  start = Time.current
  post webhooks_vapi_path, params: webhook_payload(trial)
  visit trial_session_path(trial.code)
  
  expect(page).to have_css('#trial_calls .call-card', wait: 3)
  expect(Time.current - start).to be < 3.seconds
end
```

**Reference Sections:** start.md Phase 2, Section 10.5 (UI Definition of Done), Section 11 (SLIs/SLOs)

**Estimated Duration:** 2 sprints (4 weeks, Sprint 4 is 100% mini-report polish)

---

### E-004: Payments (Phase 3) — 2 Sprints, 22pts

**Objective:** Convert trial users to paid via Stripe Checkout, create Business with uncapped assistant.

**Recommended Ticket Breakdown (8 tickets):**

```
SPRINT 5 (Stripe Integration - 12pts):
T3-01: Stripe client + circuit breaker (3pts)
T3-02: Checkout session controller (redirect to Stripe) (3pts)
T3-03: Stripe webhook handler (checkout.session.completed) (3pts)
T3-04: ConvertTrialToBusinessJob (clone assistant, create Business) (5pts)

SPRINT 6 (Business Creation + Idempotency - 10pts):
T3-05: Business model + unique constraints (3pts)
T3-06: Onboarding shell page (post-purchase redirect) (2pts)
T3-07: Idempotency testing (concurrent webhooks) (3pts)
T3-08: Agent-ready email (welcome to paid) (2pts)
```

**TDD Workflow:**
- **Critical: Write idempotency tests FIRST**
  ```ruby
  # spec/jobs/convert_trial_to_business_job_spec.rb
  it "handles duplicate checkout webhooks safely" do
    trial = create(:trial_session)
    
    # Process same checkout.session.completed twice
    2.times do
      ConvertTrialToBusinessJob.perform_now(
        trial_session_id: trial.id,
        stripe_subscription_id: "sub_123"
      )
    end
    
    # Only 1 Business created (unique constraint prevents duplicates)
    expect(Business.where(trial_session_id: trial.id).count).to eq(1)
  end
  ```

- **Then webhook flow:**
  1. Create VCR cassette for Stripe webhook payload
  2. Write request spec for webhook signature verification
  3. Write job spec for Business creation
  4. Implement controller → job → model

**Common Pitfalls:**
- Missing unique index on `businesses.stripe_subscription_id` (allows duplicates)
- Not verifying Stripe webhook signature (security hole)
- Hardcoding Stripe price IDs (use ENV vars)
- Creating assistant without checking trial.vapi_assistant_id exists
- Not handling Stripe API errors (card declined, etc.)

**Race Condition Prevention (Critical):**
```ruby
# Migration - REQUIRED
add_index :businesses, :trial_session_id, unique: true
add_index :businesses, :stripe_subscription_id, unique: true

# Job - Handle gracefully
begin
  business = Business.create!(...)
rescue ActiveRecord::RecordNotUnique
  # Another webhook beat us - fetch existing record
  business = Business.find_by!(stripe_subscription_id: subscription_id)
end
```

**Reference Sections:** start.md Phase 3, Section 14.5 (Quick Reference: Race Conditions)

**Estimated Duration:** 2 sprints (3-4 weeks with Stripe testing complexity)

---

### E-005: Admin Panel (Phase 4 P4-01) — 1 Sprint, 16pts

**Objective:** Operational debuggability without SSH access for webhook/conversion issues.

**Recommended Ticket Breakdown (4 tickets):**

```
SPRINT 14 (Admin Priority - 16pts):
T4-01a: Admin authentication + RBAC (user.admin flag) (3pts)
T4-01b: Webhook event inspector (list, detail, JSON viewer) (5pts)
T4-01c: Event reprocessing endpoint (with confirmation) (3pts)
T4-01d: Entity search (Business/User/Lead by email/phone) (5pts)
```

**TDD Workflow:**
1. Write request spec for admin auth (non-admin → 404)
2. Write system spec for webhook inspector (view event, click reprocess)
3. Implement controllers + views
4. Add Stimulus controllers for search autocomplete

**UI Framework (Custom Admin):**
```
app/controllers/admin/base_controller.rb (auth guard)
app/controllers/admin/dashboard_controller.rb
app/controllers/admin/webhooks_controller.rb
app/controllers/admin/businesses_controller.rb
app/views/layouts/admin.html.erb (sidebar nav)
app/views/admin/webhooks/index.html.erb (event list)
app/views/admin/webhooks/show.html.erb (JSON viewer with syntax highlight)
```

**Common Pitfalls:**
- Not paginating webhook events (slow with 1000+ events)
- Showing raw PII in admin (mask emails/phones in views)
- Missing confirmation modal for destructive actions (reprocess)
- Not logging admin actions (audit trail required)
- Search queries causing N+1 (use includes)

**Reprocessing Safety Pattern:**
```ruby
# app/controllers/admin/webhooks_controller.rb
def reprocess
  event = WebhookEvent.find(params[:id])
  
  if event.status == 'processed'
    flash[:warning] = "Event already processed. Reprocessing is idempotent but may have side effects."
  end
  
  event.update!(status: 'received')  # Reset for reprocessing
  ReprocessWebhookJob.perform_later(event.id)
  
  redirect_to admin_webhook_path(event), notice: "Event queued for reprocessing"
end
```

**Reference Sections:** start.md Phase 4 P4-01, Section 8.6 (Runbooks)

**Estimated Duration:** 1 sprint (2 weeks, critical path)

---

### E-006: Paid Product (Phase 4 Cont.) — 2 Sprints, 25pts

**Objective:** Dedicated Twilio number, live dashboard showing inbound/outbound calls.

**Recommended Ticket Breakdown (7 tickets):**

```
SPRINT 15 (Number Provisioning - 13pts):
T4-02: PhoneNumber model + Twilio client (3pts)
T4-03: AssignTwilioNumberJob (buy number, configure voice URL) (5pts)
T4-04: Business dashboard shell (number display, stats) (3pts)
T4-05: BusinessChannel (ActionCable for live updates) (2pts)

SPRINT 16 (Dashboard + Calls - 12pts):
T4-06: Paid Vapi webhook processing (create Call records) (5pts)
T4-07: Call history table with real-time updates (5pts)
T4-08: Recording player in dashboard (reuse from mini-report) (2pts)
```

**TDD Workflow:**
1. Write job spec for AssignTwilioNumberJob (VCR for Twilio API)
2. Write request spec for paid webhook path (separate from trial)
3. Write channel spec for BusinessChannel (auth, broadcasts)
4. Write system spec for dashboard live updates (Turbo Stream)

**Common Pitfalls:**
- Using business timezone for quiet hours (WRONG - use recipient)
- Not distinguishing trial vs paid webhook paths (same controller, different logic)
- Missing lead_id linkage on Call model (add in Phase 5)
- Dashboard N+1 loading calls.business.user (use includes)
- Audio player CORS issues with Vapi recording URLs

**Twilio Integration Pattern:**
```ruby
# app/services/twilio_client.rb
def buy_local_number(area_code:, voice_url:)
  circuit_breaker.run do
    client.available_phone_numbers('US')
          .local
          .list(area_code: area_code, limit: 1)
          .first
          .phone_number
          .tap do |number|
      client.incoming_phone_numbers.create(
        phone_number: number,
        voice_url: voice_url  # Points to Vapi phone bridge
      )
    end
  end
end
```

**Reference Sections:** start.md Phase 4, Section 5 (Paid Flows)

**Estimated Duration:** 2 sprints (4 weeks with Twilio/Vapi coordination)

---

### E-007: Compliance (Phase 4.5, Parallel) — 2 Sprints, 24pts

**Objective:** TCPA compliance before first paid call (consent, quiet hours, DNC, velocity caps).

**Recommended Ticket Breakdown (9 tickets):**

```
SPRINT 15 (Parallel Track B - 12pts):
T4.5-01: Compliance models (ConsentRecord, DncNumber, AuditLog) (3pts)
T4.5-02: PhoneTimezone service (area code → timezone) (3pts)
T4.5-03: QuietHours module (recipient timezone check) (3pts)
T4.5-04: ConsentLogger service (log with IP/statement) (3pts)

SPRINT 16 (Parallel Track B - 12pts):
T4.5-05: DNC integration (API client + cache) (5pts)
T4.5-06: CallPermission service (orchestrates all checks) (5pts)
T4.5-07: Velocity caps (Redis counters) (3pts)
T4.5-08: Compliance tab UI (settings, DNC list) (3pts)
T4.5-09: DataRetentionJob (unified purge) (2pts)
```

**TDD Workflow (CRITICAL - Compliance Testing):**
```ruby
# spec/compliance/tcpa_spec.rb (dedicated compliance suite)
describe "TCPA Compliance Audit" do
  it "enforces quiet hours in RECIPIENT timezone" do
    la_phone = "+13105551234"  # Los Angeles (PST)
    
    # 8:00 AM EST = 5:00 AM PST (VIOLATION!)
    travel_to Time.zone.parse("2025-10-25 08:00:00 EST") do
      result = CallPermission.check(business: business, to_e164: la_phone)
      
      expect(result.ok).to be false
      expect(result.reason).to eq("quiet_hours")
    end
  end
  
  it "blocks DNC numbers 100% of time" do
    phone = "+15551234567"
    create(:dnc_number, business: business, phone_e164: phone)
    
    expect {
      SpeedToLeadJob.perform_now(business.id, phone)
    }.to raise_error(/DNC blocked/)
  end
  
  it "logs consent with IP and timestamp" do
    expect {
      post lead_form_path(slug), params: { phone: "+15551234567", consent: true }
    }.to change { ConsentRecord.count }.by(1)
    
    consent = ConsentRecord.last
    expect(consent.ip).to be_present
    expect(consent.consented_at).to be_within(1.second).of(Time.current)
  end
end
```

**Common Pitfalls (HIGH RISK):**
- Using `business.timezone` instead of `PhoneTimezone.lookup(phone)` ← **$500/call penalty**
- Skipping DNC check on ANY outbound path (liability)
- Not logging consent before first call (no proof of permission)
- Velocity caps using DB instead of Redis (too slow, race conditions)
- Missing audit trail for blocked calls (compliance proof)

**Timezone Detection Pattern:**
```ruby
# app/services/phone_timezone.rb
class PhoneTimezone
  AREA_CODE_TZ = {
    '212' => 'America/New_York',    # NYC
    '310' => 'America/Los_Angeles', # LA
    '312' => 'America/Chicago',     # Chicago
    '415' => 'America/Los_Angeles', # SF
    # ... complete mapping (all 3-digit US area codes)
  }.freeze
  
  def self.lookup(e164_phone)
    area_code = e164_phone.gsub(/\D/, '')[1..3]  # Extract after country code
    AREA_CODE_TZ[area_code] || 'America/Chicago'  # Central as fallback
  end
end
```

**Reference Sections:** start.md Phase 4.5, Critical Implementation Notes #4

**Estimated Duration:** 2 sprints (parallel with E-006, 4 weeks)

---

### E-008: Speed-to-Lead (Phase 5) — 2 Sprints, 20pts

**Objective:** Hosted lead form triggers immediate outbound call, links lead to call on dashboard.

**Recommended Ticket Breakdown (7 tickets):**

```
SPRINT 7 (Lead Infrastructure - 11pts):
T5-01: Lead models (Lead, LeadSource) + migrations (3pts)
T5-02: Leads::Upsert service (phone/email deduplication) (3pts)
T5-03: SpeedToLeadJob (immediate outbound) (3pts)
T5-04: Seed hosted_form LeadSource on Business creation (2pts)

SPRINT 8 (Hosted Form + Dashboard - 9pts):
T5-05: LeadFormsController (public /l/:slug) (3pts)
T5-06: Lead form UI (mobile-optimized, consent checkbox) (3pts)
T5-07: Leads dashboard tab (table with call linkage) (3pts)
T5-08: Lead notification email (new lead alert) (2pts)
```

**TDD Workflow:**
1. Write service spec for Leads::Upsert (deduplication logic)
2. Write job spec for SpeedToLeadJob (with compliance checks)
3. Write request spec for public form (throttling, consent)
4. Write system spec for E2E (form → call → dashboard)

**Common Pitfalls:**
- Not normalizing phone before deduplication (creates duplicates)
- Missing consent checkbox on hosted form (TCPA violation)
- Form throttling too aggressive (blocks legitimate submissions)
- Not linking Call.lead_id after webhook (orphaned calls)
- Dashboard query loads all leads (add pagination)

**Lead Deduplication Pattern:**
```ruby
# app/services/leads/upsert.rb
module Leads
  class Upsert
    def self.call(business:, lead_source:, attrs:)
      phone = attrs[:phone].to_s.gsub(/\D/, '')
      phone = "+1#{phone}" unless phone.start_with?('+')
      
      # Try phone first, then email
      lead = business.leads.find_by(phone: phone) ||
             business.leads.find_by(email: attrs[:email])
      
      if lead
        lead.update!(attrs.merge(lead_source: lead_source))
      else
        lead = business.leads.create!(attrs.merge(lead_source: lead_source))
      end
      
      lead
    end
  end
end
```

**Reference Sections:** start.md Phase 5, Section 5 (Speed-to-Lead Flow)

**Estimated Duration:** 2 sprints (3-4 weeks)

---

### E-009: Analytics & Reporting (Phase 6) — 2 Sprints, 20pts

**Objective:** Dashboard tiles (7-day counts), daily email reports, operational autonomy (<2hrs/week).

**Recommended Ticket Breakdown (8 tickets):**

```
SPRINT 9 (Analytics Infrastructure - 11pts):
T6-01: AnalyticsDaily model + migrations (3pts)
T6-02: AnalyticsComputer service (counts/averages only) (3pts)
T6-03: AnalyticsIngestJob (after_commit hooks) (3pts)
T6-04: DailyRollupJob (02:00 local finalization) (3pts)

SPRINT 10 (Reporting + Admin - 9pts):
T6-05: Analytics dashboard (7-day tiles, no charts) (3pts)
T6-06: DailyReportJob + email template (5pts)
T6-07: System analytics (admin MRR/conversion) (3pts)
T6-08: Performance optimization (<500ms @ 50 calls) (2pts)
```

**TDD Workflow:**
1. Write unit spec for AnalyticsComputer (deterministic outputs)
2. Write job spec for ingest (idempotent upserts)
3. Write mailer spec for daily report (correct KPIs)
4. Write performance spec for dashboard (benchmark)

**Analytics Formulas (MVP - Counts Only):**
```ruby
# app/services/analytics_computer.rb
class AnalyticsComputer
  def self.for_business_day(business_id:, day:)
    calls = Call.where(business_id: business_id, created_at: day.all_day)
    leads = Lead.where(business_id: business_id, created_at: day.all_day)
    
    {
      calls_total: calls.count,
      calls_answered: calls.where('duration_seconds >= ?', 10).count,
      leads_new: leads.count,
      booked: calls.where(intent: 'scheduling').count,  # Simplified
      unique_callers: calls.distinct.count(:caller_phone),
      aht_s_avg: calls.where('duration_seconds >= ?', 10).average(:duration_seconds).to_i
      # Percentiles marked [POST-LAUNCH] - use averages for MVP
    }
  end
end
```

**Common Pitfalls:**
- Computing percentiles in Ruby (slow) - use averages initially
- Not using partial indexes (where created_at > 30 days ago)
- Missing timezone handling for DailyReportJob scheduling
- Email opens not tracked (use SendGrid webhook)
- Dashboard causes N+1 loading business.calls.count (counter cache)

**Performance Budget (Enforce):**
```ruby
# spec/performance/dashboard_spec.rb
it "loads dashboard in <500ms with 50 calls" do
  business = create(:business)
  create_list(:call, 50, business: business)
  
  benchmark = Benchmark.measure do
    get business_dashboard_path(business)
  end
  
  expect(benchmark.real).to be < 0.5
end
```

**Reference Sections:** start.md Phase 6, Section 9.5 (Analytics Instrumentation)

**Estimated Duration:** 2 sprints (3-4 weeks)

---

## 6. Ticket Template & Format Guide

### Recommended Ticket Structure

Every ticket should include these sections (adapt based on complexity):

```markdown
# [TICKET-ID]: [Title] (Epic: E-XXX | Points: X | Priority: PX)

## Context
Why this ticket exists and how it fits into the epic/phase.
Reference specific start.md sections.

## Implementation Hints
- Files to create/modify
- Key classes/methods
- Patterns from start.md to follow
- ENV vars needed

## Acceptance Criteria (Gherkin)
GIVEN [initial state]
WHEN [action taken]
THEN [expected outcome]
AND [additional verification]

## How to Test (TDD)
# Spec file structure
# Key test cases to write FIRST
# VCR cassettes needed
# Performance/accessibility checks

## Common Gotchas
⚠️ [Pitfall 1 and how to avoid]
⚠️ [Pitfall 2 specific to this ticket]

## Reference
- start.md Section X.X (relevant patterns)
- Related tickets: [dependencies]

## Definition of Done
- [ ] Tests written before implementation
- [ ] All acceptance criteria passing
- [ ] Mobile tested (375px) if UI
- [ ] Bullet clean (no N+1)
- [ ] CI green
```

---

### Example 1: Simple Ticket (2pts - Model + Migration)

```markdown
# T5-01: Create Lead Models (Lead, LeadSource)

**Epic:** E-008 | **Points:** 3 | **Priority:** P0

## Context
Leads represent potential customers who submit hosted forms or call inbound.
LeadSource tracks which form/integration generated the lead for attribution.
Supports Phase 5 speed-to-lead functionality.

## Implementation Hints
Files to create:
- db/migrate/XXXXXX_create_leads.rb
- db/migrate/XXXXXX_create_lead_sources.rb
- app/models/lead.rb
- app/models/lead_source.rb
- spec/models/lead_spec.rb
- spec/models/lead_source_spec.rb
- spec/factories/leads.rb
- spec/factories/lead_sources.rb

Key patterns:
- Use UUID primary keys (config.generators already set)
- Unique partial indexes for phone/email deduplication
- JSONB payload column for flexible form data storage

## Acceptance Criteria
GIVEN migrations run successfully
WHEN creating Lead with phone "+15551234567"
THEN record saved with normalized phone
AND unique constraint prevents duplicate phone per business
AND associations work: lead.business, lead.lead_source, lead.calls

## How to Test (TDD)
```ruby
# spec/models/lead_spec.rb
RSpec.describe Lead do
  describe 'validations' do
    it { should belong_to(:business) }
    it { should belong_to(:lead_source).optional }
    it { should have_many(:calls) }
    
    it 'prevents duplicate phone per business' do
      business = create(:business)
      create(:lead, business: business, phone: '+15551234567')
      
      duplicate = build(:lead, business: business, phone: '+15551234567')
      expect(duplicate).not_to be_valid
    end
  end
  
  describe 'scopes' do
    it 'orders by most recent' do
      old = create(:lead, created_at: 2.days.ago)
      new = create(:lead, created_at: 1.day.ago)
      
      expect(Lead.recent.first).to eq(new)
    end
  end
end

# spec/factories/leads.rb
FactoryBot.define do
  factory :lead do
    business
    lead_source
    name { Faker::Name.name }
    phone { Faker::PhoneNumber.phone_number }
    email { Faker::Internet.email }
    channel { 'web' }
    status { 'new' }
  end
end
```

## Common Gotchas
⚠️ Don't forget partial unique indexes (phone/email can be null, so unique: true alone won't work)
⚠️ Add indexes on foreign keys (business_id, lead_source_id) for query performance
⚠️ Status enum values: new, contacted, qualified, booked, lost (define in model)

## Reference
- start.md Phase 5 Data Model section
- start.md Section 6 (Data Model high-level)

## Definition of Done
- [ ] Migrations run without errors
- [ ] Model specs passing (validations, associations, scopes)
- [ ] Factories exist and generate valid records
- [ ] Indexes present (check with `rails db:schema:dump`)
- [ ] No N+1 queries in association tests (Bullet clean)
- [ ] CI green
```

---

### Example 2: Medium Ticket (5pts - Job with External API)

```markdown
# T4-03: Implement AssignTwilioNumberJob

**Epic:** E-006 | **Points:** 5 | **Priority:** P0

## Context
After Business is created (Phase 3 checkout), we provision a dedicated Twilio number.
The number's voice URL points to Vapi's phone bridge endpoint for inbound call handling.
This job runs asynchronously to avoid blocking conversion flow.

## Implementation Hints
Files to create:
- app/jobs/assign_twilio_number_job.rb
- spec/jobs/assign_twilio_number_job_spec.rb
- spec/vcr_cassettes/twilio/buy_local_number.yml

Pattern from start.md:
- Use circuit breaker around Twilio client
- Update Business.phone_number atomically
- Broadcast Turbo Stream update to dashboard
- Handle Twilio errors gracefully (no numbers available)

## Acceptance Criteria
GIVEN Business with no phone_number assigned
WHEN AssignTwilioNumberJob.perform_later(business.id, area_code: "415")
THEN Twilio number purchased in 415 area code
AND Business.phone_number updated with E.164 format
AND Twilio voice URL set to Vapi phone bridge
AND BusinessChannel broadcasts number update to dashboard
AND job completes in <10s (SLO)

## How to Test (TDD - Write This First)
```ruby
# spec/jobs/assign_twilio_number_job_spec.rb
RSpec.describe AssignTwilioNumberJob do
  it "purchases Twilio number and updates business" do
    VCR.use_cassette('twilio/buy_local_number') do
      business = create(:business, phone_number: nil)
      
      expect {
        described_class.perform_now(business.id, area_code: '415')
      }.to change { business.reload.phone_number }.from(nil)
      
      expect(business.phone_number).to match(/^\+1415/)
    end
  end
  
  it "handles no numbers available gracefully" do
    business = create(:business)
    allow(TwilioClient).to receive(:buy_local_number)
      .and_raise(TwilioNumberUnavailable)
    
    expect {
      described_class.perform_now(business.id)
    }.to raise_error(TwilioNumberUnavailable)
    # Job retries via retry_on config
  end
  
  it "broadcasts Turbo Stream update" do
    business = create(:business)
    
    VCR.use_cassette('twilio/buy_local_number') do
      expect {
        described_class.perform_now(business.id)
      }.to have_broadcasted_to(business)
        .from(BusinessChannel)
        .with(action: :replace, target: 'business_number')
    end
  end
end

# Recording VCR cassette (one-time):
# 1. Set TWILIO_ACCOUNT_SID and TWILIO_AUTH_TOKEN in test env
# 2. Run spec once with VCR.use_cassette(record: :new_episodes)
# 3. Commit cassette to repo, future runs replay
```

## Implementation Code
```ruby
# app/jobs/assign_twilio_number_job.rb
class AssignTwilioNumberJob < ApplicationJob
  queue_as :default
  retry_on TwilioNumberUnavailable, wait: 5.minutes, attempts: 3
  retry_on StandardError, wait: :exponentially_longer, attempts: 5
  
  def perform(business_id, area_code: nil)
    business = Business.find(business_id)
    return if business.phone_number.present?  # Idempotent
    
    area_code ||= default_area_code(business)
    vapi_url = "https://api.vapi.ai/call/phone/#{business.vapi_assistant_id}"
    
    number = TwilioClient.new.buy_local_number(
      area_code: area_code,
      voice_url: vapi_url
    )
    
    business.update!(phone_number: number)
    
    # Broadcast to dashboard
    BusinessChannel.broadcast_replace_to(
      business,
      target: 'business_number',
      partial: 'businesses/number',
      locals: { business: business }
    )
  end
  
  private
  def default_area_code(business)
    # Reuse trial prospect phone area code if available
    trial = business.trial_session
    if trial&.prospect_phone.present?
      trial.prospect_phone.gsub(/\D/, '')[1..3]
    else
      '415'  # Fallback to SF
    end
  end
end
```

## Common Gotchas
⚠️ Check business.vapi_assistant_id exists before calling Twilio (job will fail otherwise)
⚠️ Use circuit breaker in TwilioClient (see start.md T0.14 pattern)
⚠️ Return early if phone_number already set (idempotent on retry)
⚠️ Don't forget retry_on configuration (Twilio can be flaky)
⚠️ VCR cassette must filter TWILIO_AUTH_TOKEN (see start.md VCR setup)

## Reference
- start.md Phase 4 "AssignTwilioNumberJob" section
- start.md T0.14 (Circuit Breaker pattern)
- start.md Section 12 (VCR setup for external APIs)

## Definition of Done
- [ ] Job spec written FIRST with VCR cassette
- [ ] Job implements retry logic (retry_on configured)
- [ ] Circuit breaker used in TwilioClient
- [ ] Idempotency tested (calling twice doesn't error)
- [ ] Turbo Stream broadcast tested (channel spec)
- [ ] Job completes in <10s (measured with Benchmark)
- [ ] CI green with VCR cassette committed
```

---

### Example 3: Complex Ticket (8pts - Controller + UI + Real-Time)

```markdown
# T2-07: Build Mini-Report Mobile-Optimized UI

**Epic:** E-003 | **Points:** 8 | **Priority:** P0 (CRITICAL PATH)

## Context
THE MOST IMPORTANT SCREEN IN THE APP. The mini-report is the emotional "aha moment" that drives 80% of trial→paid conversion (start.md Phase 2).

This ticket delivers mobile-first mini-report showing captured fields, recording player, and transcript with real-time updates via Turbo Streams.

## Implementation Hints
Files to create/modify:
- app/components/voice/call_card_component.rb (ViewComponent)
- app/components/voice/audio_player_component.rb
- app/components/voice/transcript_component.rb
- app/views/trial_sessions/show.html.erb (subscribe to Turbo Stream)
- app/javascript/controllers/audio_player_controller.js (Stimulus)
- spec/components/voice/call_card_component_spec.rb
- spec/system/mini_report_spec.rb

Layout structure (mobile-first):
```
┌─────────────────────────────────┐
│ [Limits: 2/3 calls • 120s]      │ ← Badge (updates live)
│                                 │
│ Call #1 - 2 minutes ago         │ ← Timestamp
│                                 │
│ Captured Information:           │ ← FIRST (above fold)
│ • Name: John Smith              │
│ • Phone: +1 555-123-4567        │
│ • Intent: [Lead Intake] badge   │
│                                 │
│ [▶ Play Recording] 60px button  │ ← Large tap target
│                                 │
│ Transcript (first 5 lines)      │
│ [A] Hi, this is Gary from...    │
│ [U] Hi, I'm interested in...    │
│ [Read more ↓]                   │
│                                 │
│ [Go Live with Your Agent →]     │ ← Conversion CTA
└─────────────────────────────────┘
```

## Acceptance Criteria
GIVEN trial call completed and webhook processed
WHEN user viewing /trial/:code
THEN mini-report card prepends via Turbo Stream within 3s
AND captured fields displayed FIRST (above transcript)
AND recording play button ≥60px height and width (mobile tap target)
AND works flawlessly at 375px width (iPhone SE)
AND no layout shift when card appears (CLS <0.02 measured)
AND audio player keyboard accessible (Space=play/pause, arrows=seek)
AND transcript collapsed by default (first 5 exchanges), expandable

## How to Test (TDD - Multi-Layer)

### 1. Component Specs (Write First)
```ruby
# spec/components/voice/call_card_component_spec.rb
RSpec.describe Voice::CallCardComponent do
  it "renders captured fields above transcript" do
    call = build(:trial_call, captured: { name: "John", phone: "+15551234567" })
    
    render_inline(described_class.new(call: call))
    
    # Verify DOM order (captured before transcript)
    page_html = page.native.to_html
    captured_index = page_html.index('Captured Information')
    transcript_index = page_html.index('Transcript')
    
    expect(captured_index).to be < transcript_index
  end
  
  it "renders play button with 60px minimum tap target" do
    call = build(:trial_call, recording_url: 'https://example.com/rec.mp3')
    
    render_inline(described_class.new(call: call))
    
    button = page.find('[data-controller="audio-player"]')
    # Check computed height/width (must be ≥60px)
    expect(button[:class]).to include('h-16 w-16')  # 64px in Tailwind
  end
end
```

### 2. System Spec (Write After Components)
```ruby
# spec/system/mini_report_spec.rb
RSpec.describe "Mini-Report Real-Time Display" do
  it "shows mini-report within 3s of webhook", :js do
    trial = create(:trial_session, user: user)
    sign_in user
    visit trial_session_path(trial.code)
    
    # Simulate webhook arriving
    start_time = Time.current
    post webhooks_vapi_path, params: webhook_payload(trial)
    
    # Mini-report should appear via Turbo Stream
    expect(page).to have_css('#trial_calls .call-card', wait: 3)
    expect(Time.current - start_time).to be < 3.seconds
    
    # Verify mobile layout (no horizontal scroll)
    page.driver.browser.manage.window.resize_to(375, 667)
    expect(page).not_to have_css('body', style: /overflow-x: scroll/)
  end
  
  it "displays captured fields above transcript" do
    # ... test DOM order
  end
end
```

### 3. Performance Spec (Write Last)
```ruby
# spec/performance/mini_report_spec.rb
it "has CLS <0.02 when card prepends" do
  # Use Lighthouse CI or manual measurement
  # Ensure skeleton or reserved height prevents layout shift
end
```

## Implementation: CallCard Component
```ruby
# app/components/voice/call_card_component.rb
class Voice::CallCardComponent < ViewComponent::Base
  def initialize(call:, show_upgrade_cta: false)
    @call = call
    @show_upgrade_cta = show_upgrade_cta
  end
  
  def captured_fields
    @call.captured.presence || {}
  end
  
  def intent_badge_variant
    case @call.intent
    when 'lead_intake' then 'success'
    when 'scheduling' then 'primary'
    else 'default'
    end
  end
end
```

## Common Gotchas
⚠️ Audio element must have `controls` attribute for iOS compatibility
⚠️ Use `preload="none"` to avoid loading all recordings on page load (performance)
⚠️ Transcript expansion must NOT cause layout shift (reserve height or use max-height transition)
⚠️ Turbo Stream target ID must exist before broadcast (add empty div in trial page)
⚠️ Recording URLs from Vapi may require CORS (check CSP headers)

## Reference
- start.md Phase 2 (Mini-Report as Conversion Driver)
- start.md Section 10.5 (UI Definition of Done)
- start.md T0.16 (ViewComponent patterns)

## Definition of Done
- [ ] Component specs passing (all variants tested)
- [ ] System spec passing (real-time prepend)
- [ ] ViewComponent::Preview exists (visual QA at /rails/view_components)
- [ ] Mobile tested at 375px (no horizontal scroll)
- [ ] Audio player works on iOS Safari + Chrome Android (manual test)
- [ ] Keyboard accessible (Space, arrows tested)
- [ ] Performance: Loads in <3s P95 (measured), CLS <0.02
- [ ] Bullet clean (no N+1 loading trial_session.user)
- [ ] CI green
```

---

## 7. Testing Strategy for Mid-Level Teams

### Test Pyramid (start.md Section 12 Simplified)

```
     System (5-10 tests)  ← Critical user flows only
   Request (20-30 tests)  ← Primary defense (controllers, auth)
 Unit (15-20 tests)       ← Business logic (services, models)
────────────────────────────────────────────
Total: ~60 tests/phase, <2 min suite runtime
```

**Not more.** Avoid test bloat. Focus on revenue-breaking scenarios.

### What to Test (Mandatory)

| Layer | When to Write | Example |
|-------|---------------|---------|
| **Unit** | Service objects, complex methods | `EmailNormalizer.normalize`, `PhoneTimezone.lookup` |
| **Request** | Every controller action | `POST /trial_sessions`, `POST /webhooks/vapi` |
| **Job** | Every background job | `CreateTrialAssistantJob`, `ProcessVapiEventJob` |
| **System** | Critical user flows (3-5 per phase) | Signup → trial → call → mini-report |

### What NOT to Test (Skip)

```ruby
# ❌ DON'T TEST (Rails framework behavior)
it { should belong_to(:user) }                    # Skip associations
it { should validate_presence_of(:email) }        # Skip simple validations
it { should have_db_column(:created_at) }         # Skip schema

# ✅ DO TEST (Business logic)
it "normalizes gmail +tags and dots" { ... }      # Custom logic
it "prevents duplicate trial per normalized email" { ... }  # Business rule
it "enforces quiet hours in recipient timezone" { ... }     # Compliance
```

### External API Testing (VCR Pattern)

Every external API call needs VCR cassette:

```ruby
# 1. Configure VCR (one-time, in spec/support/vcr.rb)
VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock
  c.default_cassette_options = { record: :once }
  
  # Filter secrets
  c.filter_sensitive_data('<VAPI_API_KEY>') { ENV['VAPI_API_KEY'] }
  c.filter_sensitive_data('<TWILIO_AUTH_TOKEN>') { ENV['TWILIO_AUTH_TOKEN'] }
  c.filter_sensitive_data('<STRIPE_SECRET_KEY>') { ENV['STRIPE_SECRET_KEY'] }
end

# 2. Use in specs
RSpec.describe VapiClient do
  it "creates assistant with correct payload" do
    VCR.use_cassette('vapi/create_assistant_success') do
      client = VapiClient.new
      result = client.create_assistant(name: "Test", ...)
      
      expect(result['id']).to match(/^asst_/)
    end
  end
end

# 3. Record cassette once with real API
# Run spec with VCR_RECORD_MODE=new_episodes bundle exec rspec spec/path
# Commit cassette to repo
```

### Idempotency Testing (Critical Pattern)

Every webhook/job that creates records needs this test:

```ruby
# Pattern: Concurrent processing with threads
it "handles concurrent webhook processing safely" do
  event = create(:webhook_event, event_id: "evt_123")
  
  # Simulate 2 webhooks arriving simultaneously
  threads = 2.times.map do
    Thread.new { ProcessVapiEventJob.perform_now(event.id) rescue nil }
  end
  threads.each(&:join)
  
  # Database unique constraint prevents duplicates
  expect(Call.where(vapi_call_id: "call_123").count).to eq(1)
end

# Pattern: Replay same job twice
it "is idempotent when replayed" do
  trial = create(:trial_session)
  
  2.times { CreateTrialAssistantJob.perform_now(trial.id) }
  
  # Assistant created only once
  expect(trial.reload.vapi_assistant_id).to be_present
  # No error on second run
end
```

### Performance Testing (Enforce Budgets)

```ruby
# Dashboard performance spec
it "loads in <500ms with 50 calls" do
  business = create(:business)
  create_list(:call, 50, business: business)
  sign_in business.user
  
  benchmark = Benchmark.measure do
    get business_dashboard_path(business)
  end
  
  expect(benchmark.real).to be < 0.5
  expect(response.body).to be_present  # Not just time, verify renders
end

# Bullet N+1 detection (automatic in test env)
# config/environments/test.rb
Bullet.enable = true
Bullet.raise = true  # Fails specs on N+1 detection
```

### Accessibility Testing (UI Tickets)

```ruby
# Install axe-core for automated a11y checks
# Gemfile (test group)
gem 'axe-core-rspec'

# spec/system/trial_flow_spec.rb
it "is keyboard accessible", :js do
  visit signup_path
  
  # Tab through form
  page.send_keys(:tab)  # Email input
  page.send_keys(:tab)  # Consent checkbox
  page.send_keys(:tab)  # Submit button
  
  # Verify focus visible (2px ring)
  expect(page).to have_css('button:focus-visible')
end

# Automated WCAG 2.1 AA check
it "meets accessibility standards" do
  visit trial_session_path(trial.code)
  
  expect(page).to be_axe_clean
    .according_to(:wcag21aa)
    .excluding('.third-party-widget')
end
```

---

## 8. Handoff Checklist (Complete Before Ticket Creation)

### Pre-Work Verification

Before mid-level engineers start creating detailed tickets, confirm:

#### Technical Setup
- [ ] **SendGrid account** created with API key (test + production)
- [ ] **Vapi test account** with credits for development
- [ ] **Twilio trial account** upgraded to paid (remove verified number limit)
- [ ] **Stripe test mode** configured with test products/prices created
- [ ] **Sentry project** created with DSN for dev/staging/prod
- [ ] **GitHub repo** initialized with CI/CD pipeline template
- [ ] **Staging environment** provisioned (Heroku/Fly.io/Render)

#### Access & Credentials
- [ ] All engineers have access to vendor dashboards (Vapi, Twilio, Stripe, SendGrid, Sentry)
- [ ] `.env.example` file created with all required ENV vars documented
- [ ] Rails credentials setup guide documented (credentials:edit per env)
- [ ] 1Password/LastPass shared vault for team secrets

#### Development Environment
- [ ] `bin/setup` script tested (provisions DB, installs gems, runs migrations)
- [ ] Ruby 3.3+ and Rails 7.1+ versions confirmed on all dev machines
- [ ] Postgres 15+ and Redis 7+ running locally or via Docker
- [ ] Ngrok or similar for local webhook testing documented

#### Pre-Launch Validation
- [ ] HVAC prospect list (200 contractors) scraped and filtered
- [ ] Email outreach templates finalized (see start.md Campaign 1)
- [ ] Loom recording setup for manual demos
- [ ] Landing page copy drafted (ready for validation phase)
- [ ] $200 validation budget allocated and approved

#### Documentation Readiness
- [ ] start.md read by all team members (quiz on critical sections)
- [ ] BUILD-GUIDE.md (this document) distributed
- [ ] Code review checklist (Section 3) added to GitHub PR template
- [ ] Slack channels created (#engineering, #ops-alerts, #customer-feedback)

#### Sprint Planning
- [ ] First 3 epics prioritized (E-001, E-002, E-003)
- [ ] Sprint cadence decided (1-week vs 2-week sprints)
- [ ] Point estimate baseline agreed (Fibonacci 1,2,3,5,8)
- [ ] Sprint 0 (Validation) scheduled with decision gate date
- [ ] Backlog tool selected and configured (Linear, Jira, GitHub Projects)

### Decision Log (Lock Before Ticketing)

| Decision | Choice | Rationale | Impacts |
|----------|--------|-----------|---------|
| Email Provider | SendGrid | Mature API, marketing support | Phase 1, 3, 6 email tickets |
| Admin Framework | Custom Rails views | Full control, learning opportunity | +3-5pts per admin ticket |
| Monitoring | Sentry only | Sufficient for MVP, cost-effective | All error handling tickets |
| Design System | ShadCN tokens → ViewComponents | Best of ShadCN adapted to Rails | Phase 0 T0-06, all UI |
| Feature Flags | Flipper (in-app) | Simple, Redis-backed, no external service | Experiment framework |

### Team Roles & Responsibilities

For mid-level team creating tickets:

- **Tech Lead (1):** Review ticket quality, ensure start.md alignment, final merge approval
- **Backend Engineer (1-2):** Create tickets for jobs, webhooks, services, models
- **Frontend Engineer (1):** Create tickets for ViewComponents, Stimulus controllers, UI
- **Full-Stack (1):** Create tickets spanning controller + UI + real-time (mini-report, dashboard)

### Quality Standards Agreement

All team members agree to:
- TDD workflow (specs before implementation)
- <2min test suite runtime target
- 85%+ coverage for business logic
- Mobile-first enforcement (375px tested)
- Accessibility baseline (keyboard nav, focus visible, WCAG AA contrast)
- Code review within 24 hours
- No merge without green CI + checklist complete

---

## 9. Sprint Timeline Synthesis

Based on mid-level team velocity of **12-15pts/sprint** (2-week sprints):

### Stage 1: Validate & Ship Trial (8-10 weeks)

```
Sprint 0 (Weeks 0-2): Pre-Launch Validation (non-code)
  - HVAC email campaign + manual demos
  - GATE: Minimum signal required to proceed

Sprint 1 (Weeks 3-4): Foundations (18pts)
  - Epic E-001: Rails scaffold → design system

Sprint 2 (Weeks 5-6): Trial Infrastructure (13pts)
  - Epic E-002 Part 1: Models, jobs, services

Sprint 3 (Weeks 7-8): Trial UI + Abuse (15pts)
  - Epic E-002 Part 2: Controllers, UI, throttles

Sprint 4 (Weeks 9-10): Webhook Processing (13pts)
  - Epic E-003 Part 1: Vapi webhooks, TrialCall

Sprint 5 (Weeks 11-12): Mini-Report ONLY (13pts)
  - Epic E-003 Part 2: 100% focus on mini-report perfection
```

### Stage 2: Monetize & Comply (8-10 weeks)

```
Sprint 6 (Weeks 13-14): Stripe Integration (12pts)
  - Epic E-004 Part 1: Checkout, webhooks

Sprint 7 (Weeks 15-16): Business Creation (10pts)
  - Epic E-004 Part 2: ConvertTrialToBusinessJob, idempotency

Sprint 8 (Weeks 17-18): Admin Panel (16pts)
  - Epic E-005: Admin FIRST before paid features

Sprint 9-10 (Weeks 19-22): Paid + Compliance PARALLEL
  - Track A (E-006): Twilio, dashboard, calls (25pts over 2 sprints)
  - Track B (E-007): TCPA compliance, DNC, quiet hours (24pts over 2 sprints)
```

### Stage 3: Scale & Automate (6-8 weeks)

```
Sprint 11-12 (Weeks 23-26): Speed-to-Lead (20pts)
  - Epic E-008: Hosted forms, immediate outbound, lead linking

Sprint 13-14 (Weeks 27-30): Analytics & Ops (20pts)
  - Epic E-009: Dashboard tiles, daily reports, operational autonomy
```

**Total: 30 weeks (7.5 months) for mid-level team**  
**Faster with senior devs: 18-22 weeks (start.md target)**

---

## 10. Common Patterns Reference (Quick Copy-Paste)

### Database Migration Pattern
```ruby
class CreateLeads < ActiveRecord::Migration[7.1]
  def change
    create_table :leads, id: :uuid do |t|
      t.uuid :business_id, null: false, index: true
      t.string :phone
      t.string :email
      t.jsonb :payload, null: false, default: {}
      t.timestamps
      
      # Partial unique indexes (nulls allowed)
      t.index [:business_id, :phone], unique: true, 
              where: "phone IS NOT NULL", 
              name: 'idx_unique_business_phone'
      t.index [:business_id, :email], unique: true,
              where: "email IS NOT NULL",
              name: 'idx_unique_business_email'
    end
    
    add_foreign_key :leads, :businesses
  end
end
```

### FactoryBot Pattern
```ruby
# spec/factories/trial_sessions.rb
FactoryBot.define do
  factory :trial_session do
    user
    code { SecureRandom.alphanumeric(7).upcase }
    vertical { 'hvac' }
    persona_name { 'Gary' }
    voice_id { 'rachel' }
    scenario_slug { 'lead_intake' }
    expires_at { 2.hours.from_now }
    
    # Use traits for states, not separate factories
    trait :expired do
      expires_at { 1.hour.ago }
      status { 'expired' }
    end
    
    trait :limit_reached do
      calls_used { 3 }
    end
    
    trait :with_assistant do
      vapi_assistant_id { "asst_#{SecureRandom.hex(12)}" }
    end
  end
end
```

### Service Object Pattern
```ruby
# app/services/call_permission.rb
class CallPermission
  Result = Struct.new(:ok, :reason, keyword_init: true)
  
  def self.check!(business:, to_e164:, context:)
    result = check(business: business, to_e164: to_e164, context: context)
    raise CallBlockedError, result.reason unless result.ok
    result
  end
  
  def self.check(business:, to_e164:, context:)
    # DNC check
    return deny('dnc') if business.dnc_numbers.exists?(phone_e164: to_e164)
    
    # Quiet hours (recipient timezone)
    recipient_tz = PhoneTimezone.lookup(to_e164)
    return deny('quiet_hours') unless QuietHours.allow?(recipient_tz)
    
    # Velocity caps
    return deny('velocity') if velocity_exceeded?(business.id)
    
    allow
  end
  
  private
  def self.allow; Result.new(ok: true, reason: nil); end
  def self.deny(reason); Result.new(ok: false, reason: reason); end
end
```

### Stimulus Controller Pattern (Audio Player)
```javascript
// app/javascript/controllers/audio_player_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["audio", "playButton", "progress"]
  
  connect() {
    this.audioTarget.addEventListener('timeupdate', this.updateProgress.bind(this))
  }
  
  togglePlay() {
    if (this.audioTarget.paused) {
      this.audioTarget.play()
      this.playButtonTarget.textContent = "Pause"
      this.playButtonTarget.setAttribute('aria-label', 'Pause recording')
    } else {
      this.audioTarget.pause()
      this.playButtonTarget.textContent = "Play"
      this.playButtonTarget.setAttribute('aria-label', 'Play recording')
    }
  }
  
  // Keyboard support
  handleKeydown(event) {
    if (event.code === 'Space') {
      event.preventDefault()
      this.togglePlay()
    } else if (event.code === 'ArrowLeft') {
      this.audioTarget.currentTime -= 5
    } else if (event.code === 'ArrowRight') {
      this.audioTarget.currentTime += 5
    }
  }
  
  updateProgress() {
    const percent = (this.audioTarget.currentTime / this.audioTarget.duration) * 100
    this.progressTarget.style.width = `${percent}%`
  }
}
```

---

## 11. Ticket Creation Workflow

### Step-by-Step Process for Mid-Level Engineers

**For each epic from Section 5:**

1. **Read epic strategy** (objective, pitfalls, references)
2. **Review recommended breakdown** (ticket count, sprint allocation)
3. **Create tickets using template** (Section 6 format)
4. **Add implementation hints** (file paths, class structures)
5. **Write Gherkin AC** (Given/When/Then, specific and testable)
6. **Define test approach** (which specs to write first, VCR needed?)
7. **List gotchas** (from epic pitfalls + start.md warnings)
8. **Reference start.md** (specific section numbers)
9. **Peer review** (have tech lead verify alignment)
10. **Import to backlog** (Linear/Jira with epic linkage)

### Quality Check Before Import

Each ticket must answer:
- ✅ **What:** Clear title and description
- ✅ **Why:** Context linking to epic/product goal
- ✅ **How:** Implementation hints (files, patterns, ENV vars)
- ✅ **Test:** TDD approach with spec examples
- ✅ **Done:** Checklist preventing incomplete work
- ✅ **Avoid:** Gotchas specific to this ticket

If any missing → ticket not ready for junior dev execution.

---

## 12. Next Steps After Reading This Guide

1. **Validate understanding:**
   - Quiz team on 5 critical patterns (Section 3)
   - Discuss open questions from start.md Section 1
   - Align on TDD workflow expectations

2. **Set up tooling:**
   - Complete handoff checklist (Section 8)
   - Configure development environments
   - Create PR template with quality gates

3. **Execute Sprint 0:**
   - Run HVAC validation campaign
   - Record manual demos
   - Make proceed/pivot decision

4. **Create Epic E-001 tickets:**
   - Use Section 5 (E-001 strategy) as guide
   - Use Section 6 (ticket templates) for format
   - Start with 6 tickets, 18pts total
   - Peer review before import

5. **Ship Phase 0:**
   - Execute Sprint 1 (Foundations)
   - Verify all quality gates pass
   - Demo to team (magic link auth, component gallery)

6. **Iterate:**
   - Retrospective: ticket quality, point estimation accuracy
   - Refine templates based on junior dev feedback
   - Continue with E-002 (Trial Flow)

---

## Appendix A: Tech Stack Summary

**Locked Decisions (No Changes):**
- Ruby 3.3+ / Rails 7.1+
- PostgreSQL 15+ (UUID primary keys)
- Redis 7+ (Sidekiq + ActionCable + Flipper)
- Hotwire (Turbo + Stimulus)
- Tailwind CSS + ViewComponents
- SendGrid (transactional email)
- Sentry (error tracking + alerts)
- RSpec + FactoryBot + VCR/WebMock (testing)
- Bullet (N+1 detection)

**External Services:**
- Vapi.ai (voice AI + telephony orchestration)
- Twilio (phone number provisioning)
- Stripe (payments + subscriptions)
- SendGrid (email delivery)

**Development Tools:**
- letter_opener (email preview in dev)
- Flipper (feature flags)
- Stoplight (circuit breakers)
- Standard/RuboCop (linting)

---

## Appendix B: Critical References from start.md

When creating tickets, reference these sections frequently:

**Phase Requirements:**
- Section 9: Roadmap (Phases 0-6 technical breakdown)
- Each phase has detailed ticket examples (T0.01-T0.17, P1-01-P1-13, etc.)

**Code Patterns:**
- Critical Implementation Notes (page 2): Race conditions, circuit breakers, TCPA
- Section 14.5: Quick Reference Patterns (copy-paste ready)

**Testing:**
- Section 12: Test Strategy (what to test vs skip)
- Section 12.5: "Can I Ship This?" checklist

**Quality Gates:**
- Section 10.5: UI Definition of Done
- Section 11: SLIs/SLOs (performance budgets)

**Operations:**
- Section 8.6: Runbooks (incident procedures)
- Section 8.7: Tripwire Alerts (Sentry configuration)

**Product:**
- Section 1.5: Primary ICP (HVAC focus)
- Section 2.5: Positioning & Messaging
- Section 10.6: Pre-Launch Validation (Sprint 0)

---

## Document Version History

**v1.0 (Oct 25, 2025):** Initial build guide based on start.md + analysis synthesis
- Locked 5 tech decisions (SendGrid, custom admin, Sentry, ShadCN-inspired, Flipper)
- Added junior-friendly ticket templates
- Enforced critical priorities (validation gate, mini-report, admin-first, parallel compliance)
- Estimated 30-week timeline for mid-level team (vs 18-22 weeks for senior team in start.md)

---

**End of BUILD-GUIDE.md**

This document is a living artifact. Update it when:
- Tech decisions change (e.g., swap SendGrid for Postmark)
- Patterns emerge from shipped code (add to Section 10)
- Retrospectives identify gaps (refine ticket template)
- Team feedback suggests improvements (iterate on examples)

