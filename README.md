# Beaker AI - Voice-First AI Phone Agent Platform

## What is Beaker AI?

Beaker AI is a Rails application that provides voice-first AI agents for small businesses. In minutes, a prospect can experience a tailored phone agent for their business, and—once paid—go live with a dedicated number, lead capture, and a real-time dashboard.

**Core Value:** "Call hot leads in 60 seconds, not 60 minutes"—before they call your competitor.

## Tech Stack

- **Backend:** Ruby on Rails 8.1, PostgreSQL (UUID), SolidQueue/SolidCache
- **Frontend:** Turbo, Stimulus, Tailwind CSS, ViewComponents
- **Voice AI:** Vapi.ai (OpenAI + ElevenLabs)
- **Telephony:** Twilio
- **Payments:** Stripe
- **Email:** SendGrid/Resend
- **Observability:** Sentry, structured logs

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
- [x] **R1-E01-T003** - Set up SolidQueue for background jobs (3 pts) ✅ [Completed](./docs/completed_tickets/R1-E01-T003.md)
- [x] **R1-E01-T004** - Create base models: User, Trial, Assistant, Call, Business (5 pts) ✅ [Completed](./docs/completed_tickets/R1-E01-T004.md)
- [x] **R1-E01-T005** - Implement CircuitBreaker wrapper for API clients (5 pts) ✅ [Completed](./docs/completed_tickets/R1-E01-T005.md)
- [x] **R1-E01-T006** - Build webhook receiver framework with signature verification (5 pts) ✅ [Completed](./docs/completed_tickets/R1-E01-T006.md)
- [x] **R1-E01-T007** - Configure Sentry + Lograge for observability (2 pts) ✅ [Completed](./docs/completed_tickets/R1-E01-T007.md)
- [x] **R1-E01-T008** - Set up RSpec + FactoryBot + test infrastructure (3 pts) ✅ [Completed](./docs/completed_tickets/R1-E01-T008.md)
- [x] **R1-E01-T009** - Configure Rack::Attack for rate limiting (2 pts) ✅ [Completed](./docs/completed_tickets/R1-E01-T009.md)
- [x] **R1-E01-T010** - Set up GitHub Actions CI pipeline (2 pts) ✅ [Completed](./docs/completed_tickets/R1-E01-T010.md)
- [ ] **R1-E01-T011** - Deploy to staging (Fly.io/Render/Heroku) (3 pts)
- [ ] **R1-E01-T012** - Create design system foundation (tokens, components) (3 pts)

**Exit Criteria:**
- ✅ Rails app boots locally with Postgres + SolidQueue
- ✅ Magic-link auth working
- ✅ SolidQueue processing jobs
- ✅ Comprehensive test infrastructure (RSpec + FactoryBot + coverage)
- ✅ CI pipeline green
- [ ] Staging deployment successful

---

### ✅ PHASE 1: Trial Experience (15 tickets, ~52 points)

**Epic E-002: Trial Flow**

- [ ] **R1-E02-T001** - Landing page with trial signup form (3 pts)
- [ ] **R1-E02-T002** - Magic-link email delivery + UTM capture (3 pts)
- [ ] **R1-E02-T003** - Trial builder UI (industry, persona, scenario selection) (5 pts)
- [ ] **R1-E02-T004** - Vapi client: create assistant API integration (4 pts)
- [ ] **R1-E02-T005** - OpenAI KB generation service (3 pts)
- [ ] **R1-E02-T006** - CreateTrialAssistantJob implementation (4 pts)
- [ ] **R1-E02-T007** - Trial status page with ready polling (3 pts)
- [ ] **R1-E02-T008** - "Call Me Now" button + phone input UI (3 pts)
- [ ] **R1-E02-T009** - StartTrialCallJob + Vapi outbound call (4 pts)
- [ ] **R1-E02-T010** - Trial limits enforcement (3 calls, 120s cap) (3 pts)
- [ ] **R1-E02-T011** - QuietHours service (basic timezone) (2 pts)
- [ ] **R1-E02-T012** - Trial abuse prevention (email normalization, IP throttles) (4 pts)
- [ ] **R1-E02-T013** - Mobile-first responsive UI for trial flow (5 pts)
- [ ] **R1-E02-T014** - TrialReaperJob (cleanup expired trials) (2 pts)
- [ ] **R1-E02-T015** - Pre-launch validation (100 cold emails to HVAC) (5 pts)

**Exit Criteria:**
- Visitor can sign up → build personalized agent → receive call within 60s
- TTFC ≤10s P95, TTFA ≤20s P95
- Trial abuse controls working
- 5+ positive responses from HVAC outreach

---

### ✅ PHASE 2: Mini-Report (12 tickets, ~41 points)

**Epic E-003: Webhook Processing & Conversion Driver**

- [ ] **R1-E03-T001** - Vapi webhook endpoint + signature verification (3 pts)
- [ ] **R1-E03-T002** - ProcessVapiEventJob (parse call.ended) (4 pts)
- [ ] **R1-E03-T003** - LeadExtractor service (from function calls + transcript) (4 pts)
- [ ] **R1-E03-T004** - IntentClassifier service (3 pts)
- [ ] **R1-E03-T005** - TrialCall model + database migration (2 pts)
- [ ] **R1-E03-T006** - CallCard ViewComponent (with recording + transcript) (5 pts)
- [ ] **R1-E03-T007** - AudioPlayer component (keyboard accessible) (4 pts)
- [ ] **R1-E03-T008** - TrialSessionChannel + Turbo Stream updates (4 pts)
- [ ] **R1-E03-T009** - Mini-report UI (captured fields FIRST, mobile-optimized) (5 pts)
- [ ] **R1-E03-T010** - Upgrade CTA placement + tracking (2 pts)
- [ ] **R1-E03-T011** - PurgeOldTrialsJob (7-day retention) (2 pts)
- [ ] **R1-E03-T012** - Race condition prevention (unique constraints + with_lock) (3 pts)

**Exit Criteria:**
- Call ends → mini-report appears within 3s via Turbo
- Captured fields display above transcript
- Recording player works on mobile (≥60px tap target)
- Webhook→UI latency <3s P95
- No layout shift (CLS <0.02)

---

### ✅ PHASE 3: Stripe & Business Conversion (12 tickets, ~36 points)

**Epic E-004: Monetization**

- [ ] **R2-E04-T001** - Stripe client setup + API keys (2 pts)
- [ ] **R2-E04-T002** - Create Stripe products/prices (Starter $199, Pro $499) (2 pts)
- [ ] **R2-E04-T003** - Checkout session endpoint (3 pts)
- [ ] **R2-E04-T004** - Stripe webhook handler (checkout.session.completed) (4 pts)
- [ ] **R2-E04-T005** - ConvertTrialToBusinessJob (5 pts)
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

```bash
# Clone and setup
git clone <repo-url>
cd beaker-ai
bin/setup

# Start development server
bin/dev

# Run tests
bundle exec rspec

# Check code quality
bundle exec rubocop
```

### Testing Magic-Link Authentication

The app uses passwordless magic-link authentication (no passwords required):

1. Visit `http://localhost:3000/users/sign_in`
2. Enter an email address
3. Check magic link email at `http://localhost:3000/letter_opener` (in development)
4. Click "Log in to my account" link
5. You're now authenticated!

**Note:** Magic links expire after 20 minutes for security.

## Environment Variables Required

See `.env.example` for full list. Key variables:

- `DATABASE_URL` - PostgreSQL connection
- `VAPI_API_KEY` - Vapi.ai API key
- `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN` - Twilio credentials
- `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET` - Stripe keys
- `SENDGRID_API_KEY` - Email delivery
- `SENTRY_DSN` - Error tracking

**Circuit Breaker API Clients:**
- `VAPI_API_KEY` - Vapi.ai voice AI API
- `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN` - Twilio telephony services
- `STRIPE_SECRET_KEY` - Stripe payment processing
- `TWILIO_STATUS_CALLBACK_URL`, `TWILIO_VOICE_URL` - Webhook endpoints
- `STRIPE_SUCCESS_URL`, `STRIPE_CANCEL_URL` - Payment redirect URLs

See [Environment Variables Documentation](./docs/environment-variables.md) for complete API client configuration.

## Key Metrics & Success Criteria

- **TTFC (Time to First Call):** ≤10s P95
- **TTFA (Time to First Agent):** ≤20s P95
- **Trial → Paid Conversion:** >15%
- **Week 1 Success Rate:** >40%
- **Trial Call Success Rate:** >85%

## Documentation

- **start.md** - Complete product + technical specification
- **ticket-breakdown.md** - Detailed ticket breakdowns with implementation hints
- **BUILD-GUIDE.md** - Architecture decisions + patterns

## License

Proprietary - All rights reserved
