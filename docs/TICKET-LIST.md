# BEAKER AI - MASTER TICKET LIST

**Generated:** October 25, 2025  
**Total Tickets:** 130  
**Total Points:** ~350  
**Estimated Duration:** 30-35 weeks (solo dev with AI) | 18-22 weeks (senior team)

---

## QUICK NAVIGATION

- [Sprint Overview](#sprint-overview) - Timeline and milestones
- [Stage 1: Validate & Ship Trial](#stage-1-validate--ship-trial) - Weeks 0-12, 39 tickets, 125pts
- [Stage 2: Monetize & Comply](#stage-2-monetize--comply) - Weeks 13-22, 47 tickets, 161pts
- [Stage 3: Scale & Automate](#stage-3-scale--automate) - Weeks 23-30, 24 tickets, 64pts
- [Operational Tickets](#operational-tickets) - 20 tickets throughout
- [Cross-Reference Table](#cross-reference-table) - Map to start.md sections

---

## LEGEND

### Ticket ID Format
**R[Release]-E[Epic]-T[Number]** (e.g., R1-E01-T001)
- **R1** = Release 1 (MVP to first 10 customers)
- **E01-E09** = Epic number (aligned with phases)
- **T001-T999** = Sequential ticket number

### Point Scale (Fibonacci)
- **1-2pts**: Single file/class, 2-4 hours
- **3pts**: Feature area, 1 day
- **5pts**: Multi-file feature, 2 days
- **8pts**: Complex integration, 3-4 days (max, split if larger)

### Priority Levels
- **P0**: Critical path, blocks other work
- **P1**: Important, required for launch
- **P2**: Polish, can defer if needed

### Status Indicators
- 🔴 Blocked | 🟡 Ready | 🔵 In Progress | ✅ Complete

---

## SPRINT OVERVIEW

| Sprint | Weeks | Epic(s) | Points | Goal | Exit Criteria |
|--------|-------|---------|--------|------|---------------|
| **Sprint 0** | 0-2 | Validation | 0 | Validate HVAC ICP | 5+ positive responses, 1 demo OR pivot |
| **Sprint 1** | 3-4 | E-001 | 32 | Rails foundations | Auth working, components ready, CI green |
| **Sprint 2** | 5-6 | E-002 Part 1 | 13 | Trial backend | Assistant creates, caps enforced |
| **Sprint 3** | 7-8 | E-002 Part 2 | 15 | Trial UI | Signup → call working E2E |
| **Sprint 4** | 9-10 | E-003 Part 1 | 13 | Webhooks | Call data persists, idempotent |
| **Sprint 5** | 11-12 | E-003 Part 2 | 13 | Mini-report | Perfect conversion UX, <3s load |
| **Sprint 6** | 13-14 | E-004 Part 1 | 12 | Stripe checkout | Payment flow working |
| **Sprint 7** | 15-16 | E-004 Part 2 | 10 | Business creation | Trial converts to paid |
| **Sprint 8** | 17-18 | E-005 | 16 | Admin panel | Debug tools ready |
| **Sprint 9-10** | 19-22 | E-006 + E-007 | 49+41 | Paid + Compliance | PARALLEL tracks, both ship together |
| **Sprint 11-12** | 23-26 | E-008 | 20 | Speed-to-lead | Hosted forms, immediate calls |
| **Sprint 13-14** | 27-30 | E-009 | 20 | Analytics | Auto-reports, <2hr/week ops |

**Critical Milestones:**
- Week 2: V-GATE decision (proceed/pivot)
- Week 12: Trial → Paid conversion working
- Week 22: First 10 paying customers (compliance ready)
- Week 30: MVP complete (operational autonomy)

---

## STAGE 1: VALIDATE & SHIP TRIAL
**Weeks 0-12 | 39 tickets | 125 points**

### SPRINT 0: PRE-LAUNCH VALIDATION (Weeks 0-2)
**Non-Code Activities - Validates demand before engineering investment**

#### V-001: HVAC Prospect Research (0pts, 1 day)
- **Owner:** Founder
- **Goal:** 200 filtered HVAC contractors (email, phone, website, city)
- **Tools:** Yelp API, GMB scraper, LinkedIn
- **Exit:** CSV ready for outreach
- **Ref:** start.md Section 10.6

#### V-002: Cold Email Campaign (0pts, 5 days)
- **Owner:** Founder
- **Goal:** 100 personalized emails, 10/day
- **Template:** start.md Campaign 1
- **Exit:** Track opens, replies, sentiment
- **Ref:** start.md Section 10.6

#### V-003: Manual Demos (0pts, 3 days)
- **Owner:** Founder
- **Goal:** 1+ completed live demo with prospect
- **Setup:** Manual Vapi assistant config
- **Exit:** Proof trial concept works
- **Ref:** start.md Section 10.6

#### V-GATE: Proceed/Pivot Decision ⚠️ BLOCKS ALL PHASE 1 TICKETS
- **Type:** Milestone
- **Minimum Signal:** 5+ positive responses, 1 demo
- **Strong Signal:** 10+ responses, 3+ "I'd pay for this"
- **Weak Signal (<5 responses):** PIVOT - try different ICP or pain point
- **Ref:** BUILD-GUIDE.md Section 4.1

---

### EPIC E-001: FOUNDATIONS (Sprint 1, Weeks 3-4)
**32 points | 12 tickets | Goal: Production-grade Rails skeleton**

**Exit Criteria:**
- ✅ Design system ready (8 ViewComponents with previews)
- ✅ Auth working (magic links send/validate)
- ✅ Webhooks tested (idempotency verified)
- ✅ Circuit breakers functional
- ✅ CI green on sample PR

#### Infrastructure Track (18pts)

**R1-E01-T001: Rails 7.1 Scaffold** | 2pts | P0
- **Desc:** `rails new` with PostgreSQL UUIDs, Tailwind, RSpec
- **Files:** Gemfile, config/database.yml, bin/setup
- **AC:** Server boots, DB connects, Tailwind compiles
- **Tests:** Health check smoke test
- **Ref:** start.md T0.01 | ticket-breakdown.md

**R1-E01-T002: Devise + Passwordless** | 5pts | P0
- **Desc:** Magic-link auth with 20min expiry
- **Files:** app/models/user.rb, config/initializers/devise.rb
- **AC:** Magic link sends, login works, session persists
- **Tests:** Request spec (auth flow, token expiry)
- **Ref:** start.md T0.04 | ticket-breakdown.md detailed

**R1-E01-T003: Sidekiq + Redis** | 3pts | P0
- **Desc:** Background jobs with 3-tier queues (critical/default/low)
- **Files:** config/sidekiq.yml, app/jobs/application_job.rb
- **AC:** Worker runs, jobs process, /sidekiq UI accessible
- **Tests:** Job enqueue/perform spec
- **Ref:** start.md T0.03 | ticket-breakdown.md detailed

**R1-E01-T004: Core Domain Models** | 5pts | P0
- **Desc:** User, Trial, Call, Business with UUID PKs
- **Files:** db/migrate/*, app/models/*.rb, spec/factories/*.rb
- **AC:** Associations work, validations enforce, factories generate
- **Tests:** Model specs (validations, scopes), Bullet clean
- **Ref:** ticket-breakdown.md detailed

**R1-E01-T005: Circuit Breakers (Stoplight)** | 5pts | P0 ⚠️ CRITICAL
- **Desc:** Wrap Vapi/Twilio/Stripe clients with circuit breakers
- **Files:** app/services/api_client_base.rb, config/initializers/stoplight.rb
- **AC:** Opens after 5 failures, auto-resets, Sentry alerts
- **Tests:** Service specs (open/close/half-open states)
- **Ref:** start.md T0.14 | ticket-breakdown.md detailed

**R1-E01-T006: Webhook Framework** | 5pts | P0 ⚠️ CRITICAL
- **Desc:** WebhookEvent model, signature verification, fast ACK
- **Files:** app/controllers/webhooks_controller.rb, app/models/webhook_event.rb
- **AC:** All 3 providers verified, duplicates safe, <50ms ACK
- **Tests:** Request specs (signatures, idempotency, concurrent processing)
- **Ref:** start.md T0.13 | ticket-breakdown.md detailed

**R1-E01-T010: Sentry + Lograge** | 2pts | P0
- **Desc:** Error tracking + JSON structured logs
- **Files:** config/initializers/sentry.rb, config/initializers/lograge.rb
- **AC:** Sentry receives errors, logs output JSON with request_id
- **Tests:** Manual verification (trigger error)
- **Ref:** start.md T0.06

**R1-E01-T011: Rack::Attack + SecureHeaders** | 2pts | P0
- **Desc:** Rate limiting, CSP, HSTS, secure cookies
- **Files:** config/initializers/rack_attack.rb, config/initializers/secure_headers.rb
- **AC:** Throttles active (429 on abuse), security headers present
- **Tests:** Request spec (throttle enforcement)
- **Ref:** start.md T0.07

**R1-E01-T012: CI Pipeline** | 2pts | P0
- **Desc:** GitHub Actions with Postgres/Redis services
- **Files:** .github/workflows/ci.yml
- **AC:** PR triggers lint + test, all checks pass
- **Tests:** CI runs successfully on sample PR
- **Ref:** start.md T0.09

#### Design System Track (14pts)

**R1-E01-T007: Design Tokens** | 3pts | P0
- **Desc:** ShadCN-inspired CSS variables + Tailwind mapping
- **Files:** app/assets/stylesheets/tokens.css, tailwind.config.js
- **AC:** Light/dark themes, semantic tokens (--bg, --brand, etc.)
- **Tests:** Token resolution test, visual check
- **Ref:** start.md T0.15 | BUILD-GUIDE.md Decision 4

**R1-E01-T008: ViewComponents (8 primitives)** | 8pts | P0 ⚠️ CRITICAL
- **Desc:** Button, Input, Card, Badge, Dialog, Toast, Checkbox, Select
- **Files:** app/components/primitives/*.rb, spec/components/primitives/*.rb
- **AC:** All 8 with ViewComponent::Preview, keyboard accessible, mobile-tested
- **Tests:** Component specs (variants), accessibility (axe-core)
- **Ref:** start.md T0.16 | BUILD-GUIDE.md T0-06

**R1-E01-T009: Trial Flow Wireframes** | 0pts | P1
- **Desc:** Document mobile + desktop layouts for all trial states
- **Files:** docs/wireframes/trial-flow.md
- **AC:** Wireframes reviewed, copy finalized, states documented
- **Tests:** N/A (design artifact)
- **Ref:** start.md T0.17

---

### EPIC E-002: TRIAL FLOW (Sprints 2-3, Weeks 5-8)
**52 points | 15 tickets | Goal: <60s personalized trial with outbound call**

**Exit Criteria:**
- ✅ TTFA ≤20s P95 (assistant ready)
- ✅ TTFC ≤10s P95 (call initiated)
- ✅ Trial call success rate >85%
- ✅ Abuse prevention active (email normalization, IP throttles)
- ✅ Mobile-first enforced (375px tested)

#### SPRINT 2: Trial Backend (13pts)

**R1-E02-T001: Trial Migrations** | 3pts | P0
- **Desc:** scenario_templates, trial_sessions, email_subscriptions tables
- **Files:** db/migrate/*, unique indexes on code, (provider, event_id)
- **AC:** Migrations run, constraints work, UUID PKs
- **Tests:** Schema spec, factory validation
- **Ref:** start.md P1-01

**R1-E02-T002: Seed HVAC Scenario** | 2pts | P0
- **Desc:** Seed 1 template: hvac + lead_intake (version 1, active)
- **Files:** db/seeds.rb, spec/seeds_spec.rb
- **AC:** rails db:seed creates template with prompt_pack JSONB
- **Tests:** Seed spec verifies presence and shape
- **Ref:** start.md P1-02 | BUILD-GUIDE.md T1-02

**R1-E02-T003: PromptBuilder Service** | 2pts | P0
- **Desc:** Merge template + KB + persona variables
- **Files:** app/services/prompt_builder.rb, spec/services/prompt_builder_spec.rb
- **AC:** Returns {system, first_message, tools} with placeholders filled
- **Tests:** Unit spec with fixtures
- **Ref:** start.md P1-05 | BUILD-GUIDE.md T1-03

**R1-E02-T004: OpenAIClient.small_kb** | 2pts | P1
- **Desc:** Generate <500 token KB with 5s timeout + fallback
- **Files:** app/services/openai_client.rb, spec/services/openai_client_spec.rb
- **AC:** Returns Hash, falls back to defaults on timeout
- **Tests:** VCR spec (success/timeout cases)
- **Ref:** start.md P1-05

**R1-E02-T005: VapiClient** | 3pts | P0
- **Desc:** create_assistant, outbound_call, update_assistant methods
- **Files:** app/services/vapi_client.rb (extends ApiClientBase)
- **AC:** Circuit breaker wrapped, timeouts configured (5s/10s)
- **Tests:** VCR specs, circuit breaker specs
- **Ref:** start.md P1-06 | ticket-breakdown.md

**R1-E02-T006: CreateTrialAssistantJob** | 3pts | P0
- **Desc:** Generate KB → build prompt → create Vapi assistant
- **Files:** app/jobs/create_trial_assistant_job.rb
- **AC:** Sets vapi_assistant_id, retries on transient errors, idempotent
- **Tests:** Job spec with VCR, retry behavior
- **Ref:** start.md P1-08 | BUILD-GUIDE.md T1-04

**R1-E02-T007: StartTrialCallJob** | 3pts | P0
- **Desc:** Outbound call with caps, quiet hours, consent checks
- **Files:** app/jobs/start_trial_call_job.rb
- **AC:** with_lock prevents race, increments calls_used, enforces limits
- **Tests:** Job spec, cap enforcement, quiet hours mock
- **Ref:** start.md P1-09 | BUILD-GUIDE.md T1-05

**R1-E02-T008: TrialReaperJob** | 2pts | P1
- **Desc:** Hourly cron to expire old trials, delete assistants
- **Files:** app/jobs/trial_reaper_job.rb
- **AC:** Trials >2hrs set to expired, Vapi delete best-effort
- **Tests:** Time-travel spec
- **Ref:** start.md P1-10 | BUILD-GUIDE.md T1-10

#### SPRINT 3: Trial UI + Abuse Prevention (15pts)

**R1-E02-T009: SignupsController** | 3pts | P0
- **Desc:** Email + marketing consent → magic link with intent token
- **Files:** app/controllers/signups_controller.rb, app/lib/signup_intent.rb
- **AC:** Captures UTM, creates/updates User, sends magic link
- **Tests:** Request spec, consent logging, intent round-trip
- **Ref:** start.md P1-03

**R1-E02-T010: TrialSessionsController** | 5pts | P0
- **Desc:** new (builder form), create (enqueue job), show (poll ready), call (trigger)
- **Files:** app/controllers/trial_sessions_controller.rb
- **AC:** Auth required, poll ?ready=1, call enforces caps/consent
- **Tests:** Request specs (all actions), system spec (E2E)
- **Ref:** start.md P1-07 | BUILD-GUIDE.md T1-07

**R1-E02-T011: Trial Builder UI** | 3pts | P0
- **Desc:** Mobile-first form (vertical, persona, voice, style, scenario)
- **Files:** app/views/trial_sessions/new.html.erb, app/javascript/controllers/form_submit_controller.js
- **AC:** 375px tested, touch targets ≥44px, loading states
- **Tests:** System spec, component specs
- **Ref:** start.md P1-12a | BUILD-GUIDE.md T1-08

**R1-E02-T012: Email Normalizer + Throttles** | 3pts | P0
- **Desc:** Gmail +trick removal, IP-based rate limiting
- **Files:** app/services/email_normalizer.rb, config/initializers/rack_attack.rb
- **AC:** Normalizes +suffix/dots, throttles at 10/10min per IP
- **Tests:** Service spec, request spec (429 on burst)
- **Ref:** start.md P1-13 | BUILD-GUIDE.md T1-09

**R1-E02-T013: QuietHours Module** | 2pts | P0
- **Desc:** Naive timezone check (business local time, Phase 1 only)
- **Files:** app/services/quiet_hours.rb
- **AC:** Allows 8am-9pm, blocks outside (⚠️ upgrade to recipient TZ in Phase 5)
- **Tests:** Time-travel spec
- **Ref:** start.md Phase 1 QuietHours section

**R1-E02-T014: Trial Progress & Ready UI** | 3pts | P0
- **Desc:** Poll for assistant ready, show phone input + consent
- **Files:** app/views/trial_sessions/show.html.erb, app/javascript/controllers/ready_poller_controller.js
- **AC:** Progress bar, ready state, phone E.164 validation, consent required
- **Tests:** System spec (poll → ready transition)
- **Ref:** start.md P1-12b

**R1-E02-T015: Error & Edge States UI** | 3pts | P0
- **Desc:** Quiet hours, cap exceeded, timeout, invalid phone UIs
- **Files:** app/views/trial_sessions/_quiet_hours_notice.html.erb, components
- **AC:** All error states render actionable messages
- **Tests:** System spec (each error scenario)
- **Ref:** start.md P1-12d

---

### EPIC E-003: MINI-REPORT (Sprints 4-5, Weeks 9-12)
**41 points | 12 tickets | Goal: Real-time mini-report drives conversion**

**Exit Criteria:**
- ✅ Mini-report appears <3s P95 after webhook
- ✅ Captured fields FIRST (above transcript)
- ✅ Play button ≥60px tap target
- ✅ Mobile flawless at 375px
- ✅ No layout shift (CLS <0.02)
- ✅ Audio player keyboard accessible

#### SPRINT 4: Webhook Processing (13pts)

**R1-E03-T001: Webhook Migrations** | 3pts | P0
- **Desc:** webhook_events, trial_calls tables with unique constraints
- **Files:** db/migrate/*
- **AC:** Unique indexes on (provider, event_id) and vapi_call_id
- **Tests:** Migration spec, factory validation
- **Ref:** start.md P2-01

**R1-E03-T002: Vapi Webhook Controller** | 3pts | P0 ⚠️ CRITICAL
- **Desc:** POST /webhooks/vapi with signature verify, fast ACK
- **Files:** app/controllers/webhooks/vapi_controller.rb
- **AC:** <50ms ACK, idempotent, signature verified, returns 200
- **Tests:** Request spec (valid/invalid signatures, duplicates)
- **Ref:** start.md P2-02 | BUILD-GUIDE.md T2-02

**R1-E03-T003: ProcessVapiEventJob** | 5pts | P0 ⚠️ CRITICAL
- **Desc:** Parse payload, upsert TrialCall, resync calls_used, broadcast
- **Files:** app/jobs/process_vapi_event_job.rb
- **AC:** Idempotent, handles race conditions, broadcasts 2 Turbo updates
- **Tests:** Job spec, concurrent processing test (2 threads)
- **Ref:** start.md P2-03 | BUILD-GUIDE.md T2-03

**R1-E03-T004: Webhook Services** | 3pts | P0
- **Desc:** VapiPayload, LeadExtractor, IntentClassifier
- **Files:** app/services/vapi_payload.rb, app/services/lead_extractor.rb
- **AC:** Extract session_id, capture_lead data, classify intent
- **Tests:** Unit specs with fixtures
- **Ref:** start.md P2-04 | BUILD-GUIDE.md T2-04

**R1-E03-T005: TrialSessionChannel** | 2pts | P0
- **Desc:** ActionCable for Turbo Stream broadcasts
- **Files:** app/channels/trial_session_channel.rb
- **AC:** Auth check (user owns session), streams to trial page
- **Tests:** Channel spec
- **Ref:** start.md P2-06

**R1-E03-T006: PurgeOldTrialsJob** | 2pts | P1
- **Desc:** Daily job to redact transcripts/recordings >7 days (unconverted)
- **Files:** app/jobs/purge_old_trials_job.rb
- **AC:** Redacts trial_calls for status != 'converted', keeps metadata
- **Tests:** Time-travel spec
- **Ref:** start.md P2-07

#### SPRINT 5: Mini-Report UI ONLY (13pts) ⚠️ DEDICATED SPRINT

**R1-E03-T007: CallCard ViewComponent** | 5pts | P0 ⚠️ SACRED
- **Desc:** Recording player, transcript, captured fields, intent badge
- **Files:** app/components/voice/call_card_component.rb
- **AC:** Captured fields FIRST, all states (collapsed/expanded/playing)
- **Tests:** Component spec (all variants), ViewComponent::Preview
- **Ref:** start.md P2-05 | BUILD-GUIDE.md T2-06

**R1-E03-T008: AudioPlayer Component** | 3pts | P0
- **Desc:** Keyboard-accessible audio player (Space, arrows)
- **Files:** app/components/voice/audio_player_component.rb, audio_player_controller.js
- **AC:** ≥60px tap target, keyboard controls work, ARIA labels
- **Tests:** Component spec, accessibility spec (keyboard nav)
- **Ref:** start.md Section 10.5 UI specs

**R1-E03-T009: Transcript Component** | 2pts | P0
- **Desc:** Collapsible transcript (5 lines → expandable)
- **Files:** app/components/voice/transcript_component.rb
- **AC:** Collapsed by default, virtualized if >50 lines, high contrast
- **Tests:** Component spec (collapsed/expanded states)
- **Ref:** start.md Phase 2 Transcript specs

**R1-E03-T010: Mini-Report Mobile Optimization** | 3pts | P0 ⚠️ CRITICAL
- **Desc:** Perfect 375px layout, <3s load, no layout shift
- **Files:** Stimulus controllers, CSS optimizations
- **AC:** CLS <0.02, fields above fold, 60px play button, <3s load
- **Tests:** Performance spec (benchmark), CLS measurement
- **Ref:** start.md Section 10.5 | BUILD-GUIDE.md Section 4.2

**R1-E03-T011: Turbo Stream Integration** | 2pts | P0
- **Desc:** Wire broadcasts to prepend call cards + update stats
- **Files:** app/views/trial_sessions/show.html.erb
- **AC:** Real-time prepend works, no page refresh needed
- **Tests:** System spec (webhook → UI update)
- **Ref:** start.md P2-05

**R1-E03-T012: Conversion Tracking** | 2pts | P1
- **Desc:** Track mini-report views, upgrade CTA clicks (Ahoy gem)
- **Files:** app/controllers/trial_sessions_controller.rb (track events)
- **AC:** Events logged: mini_report_viewed, upgrade_initiated
- **Tests:** Event tracking spec
- **Ref:** start.md Section 9.5 Analytics

---

## STAGE 2: MONETIZE & COMPLY
**Weeks 13-22 | 47 tickets | 161 points**

### EPIC E-004: PAYMENTS (Sprints 6-7, Weeks 13-16)
**36 points | 12 tickets | Goal: Trial → Paid Business conversion**

**Exit Criteria:**
- ✅ Trial→Paid conversion >15%
- ✅ No duplicate businesses on webhook retry
- ✅ Paid assistant created (no time caps)
- ✅ Onboarding email sent
- ✅ CI green, idempotency tested

#### SPRINT 6: Stripe Integration (12pts)

**R2-E04-T001: Stripe Client + Circuit Breaker** | 3pts | P0
- **Desc:** StripeClient with checkout, subscription methods
- **Files:** app/services/stripe_client.rb
- **AC:** Circuit breaker wrapped, handles errors gracefully
- **Tests:** Service spec with Stripe stubs
- **Ref:** start.md P3-02 | BUILD-GUIDE.md T3-01

**R2-E04-T002: Checkout Endpoint** | 3pts | P0
- **Desc:** POST /stripe/checkout → Stripe Checkout Session
- **Files:** app/controllers/stripe_checkout_controller.rb
- **AC:** Auth required, redirects to Stripe, includes metadata
- **Tests:** Request spec
- **Ref:** start.md P3-03 | BUILD-GUIDE.md T3-02

**R2-E04-T003: Stripe Webhook Handler** | 3pts | P0
- **Desc:** Verify signature, create WebhookEvent, enqueue ProcessStripeEventJob
- **Files:** app/controllers/webhooks/stripe_controller.rb
- **AC:** Signature verified, duplicates safe, <50ms ACK
- **Tests:** Request spec (signatures, idempotency)
- **Ref:** start.md P3-04 | BUILD-GUIDE.md T3-03

**R2-E04-T004: ProcessStripeEventJob** | 3pts | P0
- **Desc:** Route checkout.session.completed → ConvertTrialToBusinessJob
- **Files:** app/jobs/process_stripe_event_job.rb
- **AC:** Enqueues conversion with correct params, marks processed
- **Tests:** Job spec with webhook fixtures
- **Ref:** start.md P3-05

#### SPRINT 7: Business Creation + Idempotency (10pts)

**R2-E04-T005: Business Model + Constraints** | 3pts | P0
- **Desc:** Add unique indexes on trial_session_id, stripe_subscription_id
- **Files:** db/migrate/*, app/models/business.rb
- **AC:** Unique constraints prevent duplicate conversions
- **Tests:** Model spec, concurrent job test
- **Ref:** start.md P3-06 | BUILD-GUIDE.md T3-05

**R2-E04-T006: ConvertTrialToBusinessJob** | 5pts | P0 ⚠️ CRITICAL
- **Desc:** Clone trial → create paid assistant → create Business
- **Files:** app/jobs/convert_trial_to_business_job.rb
- **AC:** Idempotent, handles race conditions, marks trial converted
- **Tests:** Job spec, concurrent webhook test (2x same subscription_id)
- **Ref:** start.md P3-06 | BUILD-GUIDE.md T3-04

**R2-E04-T007: Onboarding Shell Page** | 2pts | P0
- **Desc:** /businesses/:id/onboarding with next steps
- **Files:** app/controllers/businesses_controller.rb, app/views/businesses/onboarding.html.erb
- **AC:** Shows persona/voice confirmation, "Assign Number" CTA
- **Tests:** Request spec, system spec
- **Ref:** start.md P3-07

**R2-E04-T008: Agent-Ready Email** | 2pts | P1
- **Desc:** Mailer template for successful conversion
- **Files:** app/mailers/business_mailer.rb, app/views/business_mailer/agent_ready.html.erb
- **AC:** Sends on conversion, includes onboarding link
- **Tests:** Mailer spec
- **Ref:** start.md P3-10 | Phase 3 email template

**R2-E04-T009: Idempotency Testing Suite** | 3pts | P0
- **Desc:** Comprehensive concurrent processing tests
- **Files:** spec/jobs/convert_trial_to_business_job_spec.rb
- **AC:** 2x webhook = 1 Business, race condition handled
- **Tests:** Multi-threaded job execution
- **Ref:** BUILD-GUIDE.md T3-07

**R2-E04-T010: Upgrade CTA (Trial Page)** | 2pts | P0
- **Desc:** Prominent upgrade button in trial page
- **Files:** app/views/trial_sessions/show.html.erb
- **AC:** Visible after first call, links to checkout
- **Tests:** System spec
- **Ref:** start.md P3-08

**R2-E04-T011: Stripe Tax Configuration** | 1pt | P0
- **Desc:** Enable automatic_tax in checkout sessions
- **Files:** app/services/stripe_client.rb
- **AC:** automatic_tax: {enabled: true} in all sessions
- **Tests:** Unit spec verifies params
- **Ref:** start.md Section 3.5 Stripe Tax

**R2-E04-T012: Rack::Attack (Checkout)** | 1pt | P1
- **Desc:** Throttle /stripe/checkout endpoint
- **Files:** config/initializers/rack_attack.rb
- **AC:** 10/min per user prevents abuse
- **Tests:** Request spec
- **Ref:** start.md P3-09

---

### EPIC E-005: ADMIN PANEL (Sprint 8, Weeks 17-18)
**35 points | 10 tickets | Goal: Debug without SSH** ⚠️ SHIPS FIRST IN PHASE 4

**Exit Criteria:**
- ✅ Admin can inspect webhooks (raw JSON viewer)
- ✅ Admin can reprocess failed events
- ✅ Admin can search businesses/users/leads by email/phone
- ✅ Sidekiq queue monitoring visible
- ✅ No SSH required for conversion debugging

**R2-E05-T001: Admin Authentication + RBAC** | 3pts | P0
- **Desc:** User.admin flag, Admin::BaseController
- **Files:** db/migrate/*, app/controllers/admin/base_controller.rb
- **AC:** Non-admin → 404, admin sees nav, audit logged
- **Tests:** Request spec (auth guard)
- **Ref:** start.md P4-01a | BUILD-GUIDE.md Section 4.3

**R2-E05-T002: Webhook Event Inspector** | 5pts | P0 ⚠️ CRITICAL
- **Desc:** List webhook_events, view raw JSON, filter by status
- **Files:** app/controllers/admin/webhooks_controller.rb, views
- **AC:** Paginated list, JSON syntax highlighting, search works
- **Tests:** Request spec, system spec
- **Ref:** start.md P4-01b | BUILD-GUIDE.md P4-01b

**R2-E05-T003: Event Reprocessing** | 3pts | P0
- **Desc:** Admin can manually reprocess failed webhooks
- **Files:** app/jobs/reprocess_webhook_event_job.rb
- **AC:** Resets status, enqueues job, confirms idempotency
- **Tests:** Job spec, request spec (with confirmation modal)
- **Ref:** start.md P4-01c | Section 8.6 Runbooks

**R2-E05-T004: Entity Search** | 5pts | P0
- **Desc:** Search Business/User/Lead by email/phone/ID
- **Files:** app/controllers/admin/search_controller.rb
- **AC:** Fuzzy search, results paginated, PII masked in logs
- **Tests:** Request spec, search accuracy test
- **Ref:** start.md P4-01d

**R2-E05-T005: Sidekiq Queue Monitor** | 2pts | P1
- **Desc:** Embed Sidekiq::Web in admin with auth
- **Files:** config/routes.rb (mount Sidekiq::Web)
- **AC:** Admin-only access, shows queue depths
- **Tests:** Request spec (auth required)
- **Ref:** BUILD-GUIDE.md Admin capabilities

**R2-E05-T006: Admin Dashboard** | 3pts | P1
- **Desc:** Overview with system health metrics
- **Files:** app/controllers/admin/dashboard_controller.rb
- **AC:** Shows today/7d totals, error rates, circuit breakers
- **Tests:** Request spec
- **Ref:** start.md Phase 6 admin section

**R2-E05-T007: Trial Expiration Override** | 2pts | P2
- **Desc:** Admin can extend trial expiry (support requests)
- **Files:** app/controllers/admin/trials_controller.rb
- **AC:** Updates expires_at, logs audit event
- **Tests:** Request spec, audit log verification
- **Ref:** BUILD-GUIDE.md Admin capabilities

**R2-E05-T008: DNC List Management UI** | 3pts | P1
- **Desc:** Admin can view/add/remove DNC entries
- **Files:** app/controllers/admin/dnc_controller.rb
- **AC:** Upload CSV, individual add/delete, audit logged
- **Tests:** Request spec, CSV upload test
- **Ref:** start.md Phase 4.5 DNC section

**R2-E05-T009: Cost Monitoring Dashboard** | 3pts | P1
- **Desc:** Track Vapi/Twilio spend, alert on overruns
- **Files:** app/controllers/admin/costs_controller.rb
- **AC:** Daily spend shown, P90 cost/trial, budget alerts
- **Tests:** Request spec, calculation accuracy
- **Ref:** start.md Section 8.7 Tripwire Alerts

**R2-E05-T010: Admin Audit Log Viewer** | 3pts | P2
- **Desc:** View all admin actions (reprocess, search, DNC changes)
- **Files:** app/controllers/admin/audit_logs_controller.rb
- **AC:** Paginated, filterable by action/user/date
- **Tests:** Request spec
- **Ref:** start.md Phase 4.5 audit_logs table

---

### EPIC E-006: PAID PRODUCT (Sprints 9-10, Weeks 19-22, Track A)
**49 points | 14 tickets | Goal: Dedicated number + live dashboard**

**Exit Criteria:**
- ✅ Twilio number assigned
- ✅ Inbound calls logged
- ✅ Dashboard updates in real-time
- ✅ Week 1 success >40%
- ✅ Dashboard <500ms @ 50 calls

#### SPRINT 9: Number Provisioning (13pts)

**R2-E06-T001: Calls Model (Paid)** | 3pts | P0
- **Desc:** Create calls table (separate from trial_calls), add lead_id FK
- **Files:** db/migrate/create_calls.rb
- **AC:** Unique vapi_call_id, business_id FK, lead_id optional
- **Tests:** Migration spec, factory validation
- **Ref:** start.md P4-02

**R2-E06-T002: TwilioClient** | 3pts | P0
- **Desc:** buy_local_number, update_number_webhook methods
- **Files:** app/services/twilio_client.rb (extends ApiClientBase)
- **AC:** Circuit breaker wrapped, voice_url configurable
- **Tests:** VCR spec, circuit breaker test
- **Ref:** start.md P4-03 | BUILD-GUIDE.md T4-02

**R2-E06-T003: AssignTwilioNumberJob** | 5pts | P0
- **Desc:** Buy number, set voice URL to Vapi bridge, broadcast update
- **Files:** app/jobs/assign_twilio_number_job.rb
- **AC:** Number purchased, Business.phone_number set, Turbo broadcast
- **Tests:** Job spec with VCR, idempotency test
- **Ref:** start.md P4-04 | ticket-breakdown.md detailed

**R2-E06-T004: BusinessChannel** | 2pts | P0
- **Desc:** ActionCable for dashboard live updates
- **Files:** app/channels/business_channel.rb
- **AC:** Auth check (user owns business), streams work
- **Tests:** Channel spec
- **Ref:** start.md P4-07

#### SPRINT 10: Dashboard + Calls (12pts)

**R2-E06-T005: Paid Vapi Webhook Processing** | 5pts | P0
- **Desc:** Extend ProcessVapiEventJob to create Call (not TrialCall)
- **Files:** app/jobs/process_vapi_event_job.rb (add process_paid method)
- **AC:** Creates Call, handles race conditions, broadcasts to BusinessChannel
- **Tests:** Job spec, concurrent processing test
- **Ref:** start.md P4-06 | Phase 4 webhook section

**R2-E06-T006: Business Dashboard Shell** | 3pts | P0
- **Desc:** Number display, KPI tiles (7d calls/leads), recent calls list
- **Files:** app/controllers/businesses_controller.rb, app/views/businesses/dashboard.html.erb
- **AC:** Shows number (or assign CTA), stats, subscribes to Turbo
- **Tests:** Request spec, system spec
- **Ref:** start.md P4-08

**R2-E06-T007: Call History Table (Real-Time)** | 5pts | P0
- **Desc:** Recent calls list with Turbo prepends
- **Files:** app/views/calls/_call.html.erb (reuse CallCard)
- **AC:** Prepends on webhook, shows recording/transcript
- **Tests:** System spec (Turbo broadcast)
- **Ref:** start.md P4-07

**R2-E06-T008: Usage Alerts** | 3pts | P0
- **Desc:** 80%/100% quota warnings, overage calculation
- **Files:** app/views/businesses/_usage_alert.html.erb
- **AC:** Yellow at 80%, orange at 100%, shows overage amount
- **Tests:** Component spec (variants), calculation test
- **Ref:** start.md P4-08 usage alerts | Section 3.5 pricing

**R2-E06-T009: Empty States** | 2pts | P1
- **Desc:** No calls yet, no number assigned
- **Files:** app/views/businesses/_empty_state.html.erb
- **AC:** Clear CTAs, copy matches start.md specs
- **Tests:** Component spec
- **Ref:** start.md Phase 4 empty states

**R2-E06-T010: Dashboard Performance Optimization** | 2pts | P0
- **Desc:** Eager loading, counter caches, query optimization
- **Files:** app/controllers/businesses_controller.rb
- **AC:** <500ms with 50 calls, Bullet clean
- **Tests:** Performance spec (benchmark)
- **Ref:** start.md Section 11 SLOs

**R2-E06-T011: UpdateAssistantServerUrlJob** | 2pts | P1
- **Desc:** Patch assistant serverUrl to include businessId
- **Files:** app/jobs/update_assistant_server_url_job.rb
- **AC:** Vapi assistant updated, webhook correlation easier
- **Tests:** Job spec with VCR
- **Ref:** start.md P4-05

**R2-E06-T012: Mobile Dashboard Optimization** | 3pts | P0
- **Desc:** Bottom nav, responsive grid, touch targets
- **Files:** app/views/layouts/_mobile_nav.html.erb
- **AC:** Works at 375px, bottom nav present, no horizontal scroll
- **Tests:** System spec (mobile viewport)
- **Ref:** start.md Section 10.5 mobile requirements

**R2-E06-T013: Number Assigned Email** | 2pts | P2
- **Desc:** Optional email when number provisioned
- **Files:** app/mailers/business_mailer.rb
- **AC:** Sends with number + tips
- **Tests:** Mailer spec
- **Ref:** start.md P4-11

**R2-E06-T014: Dashboard Loading States** | 2pts | P1
- **Desc:** Skeleton screens prevent layout shift
- **Files:** app/views/businesses/_skeleton.html.erb
- **AC:** Reserved heights, no CLS, smooth transitions
- **Tests:** Visual spec (CLS <0.02)
- **Ref:** start.md Phase 4 loading states

---

### EPIC E-007: COMPLIANCE (Sprints 9-10, Weeks 19-22, Track B)
**41 points | 11 tickets | Goal: TCPA-ready** ⚠️ RUNS PARALLEL WITH E-006

**Exit Criteria:**
- ✅ Quiet hours in RECIPIENT timezone (not business)
- ✅ DNC blocks 100% of calls
- ✅ Consent logged with IP/timestamp
- ✅ Velocity caps enforced
- ✅ call_blocked_quiet_hours events >0/day

#### SPRINT 9: Compliance Models (12pts, Parallel Track B)

**R2-E07-T001: Compliance Migrations** | 3pts | P0
- **Desc:** compliance_settings, consents, dnc_numbers, audit_logs tables
- **Files:** db/migrate/*
- **AC:** All tables created, unique constraints, indexes
- **Tests:** Migration spec
- **Ref:** start.md P4.5 Phase 4.5 migrations

**R2-E07-T002: PhoneTimezone Service** | 3pts | P0 ⚠️ CRITICAL
- **Desc:** Area code → timezone mapping (all US area codes)
- **Files:** app/services/phone_timezone.rb
- **AC:** lookup("+13105551234") returns "America/Los_Angeles"
- **Tests:** Unit spec with 10+ area codes
- **Ref:** start.md P4.5 PhoneTimezone | BUILD-GUIDE.md Pattern 4

**R2-E07-T003: QuietHours (Recipient Timezone)** | 3pts | P0 ⚠️ CRITICAL
- **Desc:** Upgrade from Phase 1 naive implementation
- **Files:** app/services/quiet_hours.rb
- **AC:** Uses PhoneTimezone.lookup, enforces 8am-9pm recipient time
- **Tests:** TCPA spec (NYC business → LA lead at 8:30am EST = violation)
- **Ref:** start.md Critical Notes #4 | BUILD-GUIDE.md T4.5-03

**R2-E07-T004: ConsentLogger Service** | 3pts | P0
- **Desc:** Log all consents with IP, statement snapshot, timestamp
- **Files:** app/services/consent_logger.rb
- **AC:** Creates Consent record, includes all required fields
- **Tests:** Service spec, request integration
- **Ref:** start.md P4.5 ConsentLogger | BUILD-GUIDE.md T4.5-04

#### SPRINT 10: Enforcement (12pts, Parallel Track B)

**R2-E07-T005: DNC Number Model + API** | 5pts | P0
- **Desc:** Store DNC list, check before every outbound
- **Files:** app/models/dnc_number.rb, app/services/dnc_checker.rb
- **AC:** Unique (business_id, phone_e164), blocks calls
- **Tests:** Model spec, integration test (call blocked)
- **Ref:** start.md Phase 4.5 DNC | BUILD-GUIDE.md T4.5-05

**R2-E07-T006: CallPermission Service** | 5pts | P0 ⚠️ CRITICAL
- **Desc:** Orchestrates all checks (DNC, quiet hours, velocity, caps)
- **Files:** app/services/call_permission.rb
- **AC:** Returns Result(ok, reason), logs audit on deny
- **Tests:** Service spec (all denial reasons), integration tests
- **Ref:** start.md Phase 4.5 CallPermission | BUILD-GUIDE.md T4.5-06

**R2-E07-T007: Velocity Caps (Redis)** | 3pts | P0
- **Desc:** Per-minute and daily outbound caps via Redis counters
- **Files:** app/services/call_permission.rb (velocity methods)
- **AC:** 5/min and 50/day enforced, Redis keys expire
- **Tests:** Service spec, time-based test
- **Ref:** start.md Phase 4.5 velocity | BUILD-GUIDE.md T4.5-07

**R2-E07-T008: Compliance Settings UI** | 3pts | P1
- **Desc:** Business compliance tab (quiet hours, caps, recording)
- **Files:** app/views/businesses/compliance.html.erb
- **AC:** Update settings, show current values, audit logged
- **Tests:** System spec
- **Ref:** start.md Phase 4.5 compliance tab | BUILD-GUIDE.md T4.5-08

**R2-E07-T009: DataRetentionJob (Unified)** | 2pts | P1
- **Desc:** Daily purge of transcripts per retention policy
- **Files:** app/jobs/data_retention_job.rb
- **AC:** Redacts trials >7d, paid per policy, idempotent
- **Tests:** Time-travel spec
- **Ref:** start.md Phase 4.5 retention | BUILD-GUIDE.md T4.5-09

**R2-E07-T010: Integrate CallPermission** | 3pts | P0
- **Desc:** Wire CallPermission into StartTrialCallJob + SpeedToLeadJob
- **Files:** app/jobs/start_trial_call_job.rb, app/jobs/speed_to_lead_job.rb
- **AC:** All outbound calls gated, denials logged
- **Tests:** Job spec (enforcement), audit verification
- **Ref:** start.md Phase 4.5 integration

**R2-E07-T011: TCPA Compliance Test Suite** | 5pts | P0 ⚠️ CRITICAL
- **Desc:** Dedicated spec/compliance/ directory with audit tests
- **Files:** spec/compliance/tcpa_spec.rb
- **AC:** Tests DNC block, quiet hours (recipient TZ), consent logging
- **Tests:** ALL compliance scenarios (see start.md Section 12.5)
- **Ref:** start.md Section 12 compliance suite | BUILD-GUIDE.md E-007

**R2-E07-T012: Unsubscribe + DNC Opt-Out** | 4pts | P1
- **Desc:** Self-serve /u/:token (email) and /dnc/:token (calls)
- **Files:** app/controllers/unsubscribes_controller.rb, dnc_controller.rb
- **AC:** Signed tokens verified, opt-outs persisted, audit logged
- **Tests:** Request spec (valid/invalid tokens)
- **Ref:** start.md Phase 4.5 unsubscribe section

---

## STAGE 3: SCALE & AUTOMATE
**Weeks 23-30 | 24 tickets | 64 points**

### EPIC E-008: SPEED-TO-LEAD (Sprints 11-12, Weeks 23-26)
**27 points | 11 tickets | Goal: Hosted forms trigger immediate calls**

**Exit Criteria:**
- ✅ Lead form → call → dashboard E2E working
- ✅ Speed-to-ring ≤10s
- ✅ Lead deduplication working
- ✅ Consent enforced on hosted form

#### SPRINT 11: Lead Infrastructure (11pts)

**R3-E08-T001: Lead Migrations** | 3pts | P0
- **Desc:** lead_sources, leads tables with deduplication indexes
- **Files:** db/migrate/*
- **AC:** Unique (business_id, phone), unique (business_id, email)
- **Tests:** Migration spec, factory validation
- **Ref:** start.md P5-01 | BUILD-GUIDE.md T5-01

**R3-E08-T002: Leads::Upsert Service** | 3pts | P0
- **Desc:** Phone/email normalization + deduplication logic
- **Files:** app/services/leads/upsert.rb, app/services/lead_normalizer.rb
- **AC:** Finds existing by phone or email, updates payload
- **Tests:** Service spec (dedup scenarios)
- **Ref:** start.md P5-02 | BUILD-GUIDE.md T5-02

**R3-E08-T003: SpeedToLeadJob** | 3pts | P0
- **Desc:** Immediate outbound call to lead with compliance checks
- **Files:** app/jobs/speed_to_lead_job.rb
- **AC:** Calls within 10s, uses CallPermission, timestamps lead
- **Tests:** Job spec, compliance integration
- **Ref:** start.md P5-03 | BUILD-GUIDE.md T5-03

**R3-E08-T004: Seed LeadSource on Business** | 2pts | P0
- **Desc:** Create hosted_form LeadSource during conversion
- **Files:** app/jobs/convert_trial_to_business_job.rb (extend)
- **AC:** Creates source with slug=parameterized(business.name)
- **Tests:** Job spec extended
- **Ref:** start.md P5-04 | BUILD-GUIDE.md T5-04

#### SPRINT 12: Hosted Form + Dashboard (9pts)

**R3-E08-T005: LeadFormsController** | 3pts | P0
- **Desc:** Public /l/:slug endpoint with consent + throttles
- **Files:** app/controllers/lead_forms_controller.rb
- **AC:** Consent required, creates lead, enqueues SpeedToLeadJob
- **Tests:** Request spec (throttling, consent enforcement)
- **Ref:** start.md P5-05 | BUILD-GUIDE.md T5-05

**R3-E08-T006: Lead Form UI** | 3pts | P0
- **Desc:** Mobile-optimized form with consent checkbox
- **Files:** app/views/lead_forms/new.html.erb
- **AC:** 375px tested, consent copy finalized, hidden UTM fields
- **Tests:** System spec, accessibility
- **Ref:** start.md P5-06 | BUILD-GUIDE.md T5-06

**R3-E08-T007: Leads Dashboard Tab** | 3pts | P0
- **Desc:** List leads with call linkage, status pills
- **Files:** app/controllers/leads_controller.rb, app/views/leads/index.html.erb
- **AC:** Paginated, shows status, links to call detail
- **Tests:** Request spec, system spec
- **Ref:** start.md P5-07 | BUILD-GUIDE.md T5-07

**R3-E08-T008: Lead Notification Email** | 2pts | P1
- **Desc:** Email owner on new lead with call recording
- **Files:** app/mailers/lead_mailer.rb
- **AC:** Sends on lead creation, includes recording link
- **Tests:** Mailer spec
- **Ref:** start.md P5-10

**R3-E08-T009: Webhook Lead Linking** | 3pts | P0
- **Desc:** ProcessVapiEventJob attaches Call to Lead via phone/email
- **Files:** app/jobs/process_vapi_event_job.rb (extend process_paid)
- **AC:** Links by captured data or caller_phone, updates lead status
- **Tests:** Job spec with fixtures
- **Ref:** start.md P5-06 webhook section

**R3-E08-T010: Default Scenario Settings** | 2pts | P1
- **Desc:** Business can choose default scenario
- **Files:** app/controllers/businesses_controller.rb (settings action)
- **AC:** Updates default_scenario_slug, UI shows current
- **Tests:** Request spec
- **Ref:** start.md P5-08

**R3-E08-T011: hCaptcha Integration (Flag-Gated)** | 2pts | P2
- **Desc:** Optional anti-spam for hosted forms
- **Files:** config/initializers/flipper.rb, lead_forms controller
- **AC:** Behind enable_hcaptcha flag, validates token
- **Tests:** Request spec (flag on/off)
- **Ref:** start.md P5-09

---

### EPIC E-009: ANALYTICS & REPORTING (Sprints 13-14, Weeks 27-30)
**37 points | 13 tickets | Goal: <2hr/week ops time**

**Exit Criteria:**
- ✅ Analytics tiles show 7-day data (counts only, no percentiles)
- ✅ Daily email arrives at 08:00 local
- ✅ Dashboard <500ms @ 50 calls
- ✅ MRR tracking working
- ✅ Automated jobs reduce manual ops

#### SPRINT 13: Analytics Infrastructure (11pts)

**R3-E09-T001: AnalyticsDaily Migrations** | 3pts | P0
- **Desc:** analytics_daily, analytics_system_daily tables
- **Files:** db/migrate/*
- **AC:** Unique (business_id, day), all metric columns present
- **Tests:** Migration spec
- **Ref:** start.md P6-01

**R3-E09-T002: AnalyticsComputer Service** | 3pts | P0
- **Desc:** Compute calls_total, calls_answered, leads_new, booked, aht_s_avg
- **Files:** app/services/analytics_computer.rb
- **AC:** Deterministic outputs, handles empty data
- **Tests:** Unit spec with fixtures (counts/averages ONLY, no percentiles)
- **Ref:** start.md P6-02 | BUILD-GUIDE.md T6-02

**R3-E09-T003: AnalyticsIngestJob** | 3pts | P0
- **Desc:** after_commit hook upserts today's snapshot
- **Files:** app/jobs/analytics_ingest_job.rb, app/models/call.rb (hook)
- **AC:** Triggers on Call/Lead changes, upserts analytics_daily
- **Tests:** Job spec, hook verification
- **Ref:** start.md P6-03 | BUILD-GUIDE.md T6-03

**R3-E09-T004: DailyRollupJob (TZ-Aware)** | 3pts | P0
- **Desc:** Finalize yesterday's analytics at 02:00 business local time
- **Files:** app/jobs/analytics_daily_rollup_job.rb
- **AC:** Runs per-business TZ, computes D-1, idempotent
- **Tests:** Job spec with timezone fixtures
- **Ref:** start.md P6-04 | BUILD-GUIDE.md T6-04

#### SPRINT 14: Reporting + Admin Analytics (9pts)

**R3-E09-T005: Analytics Dashboard (Tiles Only)** | 3pts | P0
- **Desc:** 7-day KPI tiles (no charts yet - POST-LAUNCH)
- **Files:** app/views/businesses/analytics.html.erb
- **AC:** Shows calls, leads, booked, AHT (7d counts)
- **Tests:** Request spec, calculation accuracy
- **Ref:** start.md P6-06 | BUILD-GUIDE.md T6-05

**R3-E09-T006: DailyReportJob + Email** | 5pts | P0
- **Desc:** Send yesterday's report at 08:00 local per business
- **Files:** app/jobs/daily_report_job.rb, app/mailers/report_mailer.rb
- **AC:** TZ-aware scheduling, includes KPIs + links, skips if no activity
- **Tests:** Mailer spec, job spec with time control
- **Ref:** start.md P6-05 | BUILD-GUIDE.md T6-06

**R3-E09-T007: System Analytics** | 3pts | P1
- **Desc:** Platform-wide MRR, conversions, trials
- **Files:** app/jobs/system_analytics_rollup_job.rb
- **AC:** analytics_system_daily updated, MRR calculated from Stripe
- **Tests:** Job spec
- **Ref:** start.md P6-10 | BUILD-GUIDE.md T6-07

**R3-E09-T008: Performance Optimization** | 2pts | P0
- **Desc:** Dashboard <500ms with 50 calls
- **Files:** app/controllers/businesses_controller.rb (eager loading)
- **AC:** Benchmark passes, Bullet clean, partial indexes used
- **Tests:** Performance spec
- **Ref:** start.md P6-08 | BUILD-GUIDE.md T6-08

**R3-E09-T009: CSV Exports** | 3pts | P2 [POST-LAUNCH]
- **Desc:** Stream calls/leads CSVs (build when requested)
- **Files:** app/services/call_exporter.rb, lead_exporter.rb
- **AC:** Memory-safe streaming, 100k+ records supported
- **Tests:** Export spec
- **Ref:** start.md Phase 6 exports (deferred)

**R3-E09-T010: Calls Outcome Backfill** | 2pts | P1
- **Desc:** Populate calls.outcome for historical data
- **Files:** lib/tasks/backfill.rake
- **AC:** Classifies by function_calls, safe to rerun
- **Tests:** Task spec
- **Ref:** start.md P6-08

**R3-E09-T011: Chart Infrastructure** | 3pts | P2 [POST-LAUNCH]
- **Desc:** 30-day trend charts (add when data volume justifies)
- **Files:** app/javascript/controllers/chart_controller.js
- **AC:** Chart.js integrated, responsive, accessible
- **Tests:** System spec
- **Ref:** start.md Phase 6 charts (deferred)

**R3-E09-T012: Admin MRR Dashboard** | 2pts | P1
- **Desc:** Platform revenue metrics for founder
- **Files:** app/controllers/admin/dashboard_controller.rb
- **AC:** Shows MRR trend, conversion funnel, churn
- **Tests:** Request spec
- **Ref:** start.md Phase 6 admin

**R3-E09-T013: Flipper UI Integration** | 2pts | P1
- **Desc:** Feature flag management in admin
- **Files:** config/routes.rb (mount Flipper::UI)
- **AC:** Admin can toggle flags per business
- **Tests:** Request spec (auth required)
- **Ref:** BUILD-GUIDE.md Decision 5

---

## OPERATIONAL TICKETS
**20 tickets spread across phases**

### OPS-001: Tripwire Alerts (Sentry) | 3pts | P0 | Before Stage 2 Launch
- **Desc:** Configure 11 critical alerts from start.md Section 8.7
- **Files:** config/initializers/sentry.rb
- **AC:** All alerts configured with thresholds, linked to runbooks
- **Tests:** Manual verification (trigger test alert)
- **Ref:** start.md Section 8.7 | BUILD-GUIDE.md Section 4.5

### OPS-002: Incident Runbooks | 3pts | P0 | Before Stage 2 Launch
- **Desc:** Document RB-01 through RB-05 procedures
- **Files:** docs/runbooks/*.md
- **AC:** All 5 runbooks documented, tested on staging
- **Tests:** Runbook drill (simulate failures)
- **Ref:** start.md Section 8.6

### OPS-003: Backup/Restore Testing | 5pts | P1 | Monthly
- **Desc:** Quarterly restore drill, PII anonymization script
- **Files:** scripts/restore_drill.sh, lib/tasks/anonymize.rake
- **AC:** Restore completes <30min, anonymization works
- **Tests:** Execute drill successfully
- **Ref:** start.md Section 8.6 backup strategy

### OPS-004: Monitoring Dashboards | 3pts | P1 | Before Stage 2 Launch
- **Desc:** Sentry dashboards for circuit breakers, webhooks, abuse
- **Files:** Sentry config (external)
- **AC:** Dashboard 1 (Trial Funnel), Dashboard 2 (Paid Health), Dashboard 3 (Compliance)
- **Tests:** Manual verification
- **Ref:** start.md Section 9.5 dashboards

### OPS-005: Webhook Replay Script | 2pts | P1 | Phase 2
- **Desc:** Rake task to reprocess failed webhooks
- **Files:** lib/tasks/webhooks.rake
- **AC:** Finds failed events <24h, requeues jobs
- **Tests:** Task spec
- **Ref:** start.md Section 8.6 webhook replay

### OPS-006: Trial Abuse Monitor Job | 3pts | P0 | Phase 1
- **Desc:** Hourly job auto-blocks abusive IPs/emails
- **Files:** app/jobs/trial_abuse_monitor_job.rb
- **AC:** Auto-blocks >10 trials/hr per IP, >3/day per email
- **Tests:** Job spec with abuse scenarios
- **Ref:** start.md Phase 1 Trial Abuse section

### OPS-007: Cost Monitoring Alerts | 2pts | P0 | Phase 1
- **Desc:** Alert on cost/trial P90 >$0.70
- **Files:** config/initializers/sentry.rb (custom metric)
- **AC:** Sentry alert triggers on threshold breach
- **Tests:** Manual threshold test
- **Ref:** start.md Section 8.7 cost alerts

### OPS-008: Circuit Breaker Dashboard Widget | 2pts | P1 | Phase 4
- **Desc:** Real-time circuit status in admin
- **Files:** app/views/admin/dashboard/_circuits.html.erb
- **AC:** Shows green/red indicators, trip count (24h)
- **Tests:** Component spec
- **Ref:** start.md Section 8.7 monitoring widgets

### OPS-009: Webhook Backlog Monitor | 2pts | P1 | Phase 2
- **Desc:** Alert when >100 unprocessed webhooks
- **Files:** app/jobs/webhook_backlog_monitor_job.rb
- **AC:** Checks WebhookEvent.where(status: 'received').count
- **Tests:** Job spec
- **Ref:** start.md Section 8.7 webhook backlog

### OPS-010: Performance Baseline Tests | 3pts | P1 | Phase 4
- **Desc:** Benchmark suite for critical paths
- **Files:** spec/performance/*.rb
- **AC:** Dashboard <500ms, mini-report <3s, webhook ACK <50ms
- **Tests:** Benchmark specs (all pass)
- **Ref:** start.md Section 11 SLOs

### OPS-011: Database Connection Pool Config | 1pt | P0 | Phase 0
- **Desc:** Configure pool, checkout timeout, reaping
- **Files:** config/database.yml
- **AC:** Pool=10, checkout_timeout=5, reaping_frequency=10
- **Tests:** Load test (50 concurrent requests)
- **Ref:** start.md T0.14a

### OPS-012: Bullet Gem Configuration | 1pt | P0 | Phase 0
- **Desc:** N+1 query detection in dev/test
- **Files:** config/environments/development.rb, test.rb
- **AC:** Raises on N+1 in test, shows footer in dev
- **Tests:** Intentional N+1 triggers Bullet
- **Ref:** start.md T0.14a

### OPS-013: Partial Indexes Migration | 2pts | P1 | Phase 0
- **Desc:** Add indexes for active businesses, recent calls, unconverted trials
- **Files:** db/migrate/add_partial_indexes.rb
- **AC:** Indexes created with WHERE clauses, algorithm: :concurrently
- **Tests:** Query plan analysis (EXPLAIN)
- **Ref:** start.md T0.14a

### OPS-014: VCR Cassette Re-Recording | 2pts | P2 | Quarterly
- **Desc:** Refresh API cassettes to catch schema changes
- **Files:** spec/vcr_cassettes/**/*.yml
- **AC:** All cassettes re-recorded with VCR_RECORD_MODE=all
- **Tests:** All specs still pass
- **Ref:** start.md Section 12 VCR setup

### OPS-015: Weekly Ops Cadence Setup | 1pt | P1 | Before Stage 2 Launch
- **Desc:** Document weekly checklist, automate reminders
- **Files:** docs/ops/weekly-cadence.md
- **AC:** Checklist covers all activities from start.md Section 8.6
- **Tests:** Manual execution once
- **Ref:** start.md Section 8.6 weekly ops

### OPS-016: Staging Environment Setup | 3pts | P0 | Phase 0
- **Desc:** Deploy to Fly.io/Heroku/Render with Postgres/Redis
- **Files:** fly.toml or Procfile, config/environments/staging.rb
- **AC:** /up returns 200, migrations run, webhooks reachable
- **Tests:** Manual smoke test
- **Ref:** start.md T0.10

### OPS-017: Production Deploy Pipeline | 3pts | P0 | Before Stage 2 Launch
- **Desc:** Automated deploy from main branch
- **Files:** .github/workflows/deploy.yml
- **AC:** Green CI → auto-deploy, migrations run, rollback works
- **Tests:** Deploy to staging successfully
- **Ref:** start.md Section 7 environments

### OPS-018: Secret Management | 2pts | P0 | Phase 0
- **Desc:** Rails credentials per env, 1Password vault
- **Files:** config/credentials/*.yml.enc
- **AC:** All ENV vars in credentials, .env.example documented
- **Tests:** Manual verification (all secrets load)
- **Ref:** start.md Section 7

### OPS-019: Email Warmup + Tracking | 2pts | P1 | Sprint 0
- **Desc:** SendGrid domain setup, SPF/DKIM/DMARC
- **Files:** DNS records, SendGrid config
- **AC:** Email deliverability >95%, tracking domain configured
- **Tests:** Send test email, check inbox
- **Ref:** start.md Section 10.6 email infrastructure

### OPS-020: Local Webhook Testing Setup | 2pts | P1 | Phase 1
- **Desc:** Ngrok + bin/dev:webhooks script
- **Files:** bin/dev-webhooks, README.md
- **AC:** Local webhooks reachable from Stripe CLI, Twilio test
- **Tests:** Manual webhook test
- **Ref:** start.md Section 7 local dev

---

## CROSS-REFERENCE TABLE

### start.md → TICKET-LIST Mapping

| start.md ID | TICKET-LIST ID | Title | Phase | Points |
|-------------|----------------|-------|-------|--------|
| T0.01 | R1-E01-T001 | Rails Scaffold | 0 | 2 |
| T0.02 | R1-E01-T003 | Sidekiq + Redis | 0 | 3 |
| T0.03 | R1-E01-T003 | Sidekiq + Redis | 0 | 3 |
| T0.04 | R1-E01-T002 | Devise + Passwordless | 0 | 5 |
| T0.05 | R1-E01-T008 | ViewComponents | 0 | 8 |
| T0.06 | R1-E01-T010 | Sentry + Lograge | 0 | 2 |
| T0.07 | R1-E01-T011 | Rack::Attack | 0 | 2 |
| T0.09 | R1-E01-T012 | CI Pipeline | 0 | 2 |
| T0.13 | R1-E01-T006 | Webhook Framework | 0 | 5 |
| T0.14 | R1-E01-T005 | Circuit Breakers | 0 | 5 |
| T0.14a | OPS-011 to OPS-013 | DB Pool + Bullet + Indexes | 0 | 4 |
| T0.15 | R1-E01-T007 | Design Tokens | 0 | 3 |
| T0.16 | R1-E01-T008 | ViewComponents | 0 | 8 |
| T0.17 | R1-E01-T009 | Wireframes | 0 | 0 |
| P1-01 | R1-E02-T001 | Trial Migrations | 1 | 3 |
| P1-02 | R1-E02-T002 | Seed HVAC Scenario | 1 | 2 |
| P1-03 | R1-E02-T009 | SignupsController | 1 | 3 |
| P1-04 | R1-E02-T009 | (included in T009) | 1 | - |
| P1-05 | R1-E02-T003/T004 | PromptBuilder + OpenAI | 1 | 4 |
| P1-06 | R1-E02-T005 | VapiClient | 1 | 3 |
| P1-07 | R1-E02-T010 | TrialSessionsController | 1 | 5 |
| P1-08 | R1-E02-T006 | CreateTrialAssistantJob | 1 | 3 |
| P1-09 | R1-E02-T007 | StartTrialCallJob | 1 | 3 |
| P1-10 | R1-E02-T008 | TrialReaperJob | 1 | 2 |
| P1-11 | R1-E02-T012 | Rack::Attack Throttles | 1 | 3 |
| P1-12a | R1-E02-T011 | Trial Builder UI | 1 | 3 |
| P1-12b | R1-E02-T014 | Trial Progress UI | 1 | 3 |
| P1-12c | R1-E03-T007 to T009 | Call Result Cards | 2 | 10 |
| P1-12d | R1-E02-T015 | Error States UI | 1 | 3 |
| P1-13 | R1-E02-T012 + OPS-006 | Abuse Prevention | 1 | 6 |
| P2-01 | R1-E03-T001 | Webhook Migrations | 2 | 3 |
| P2-02 | R1-E03-T002 | Vapi Webhook Controller | 2 | 3 |
| P2-03 | R1-E03-T003 | ProcessVapiEventJob | 2 | 5 |
| P2-04 | R1-E03-T004 | Webhook Services | 2 | 3 |
| P2-05 | R1-E03-T011 | Turbo Stream Integration | 2 | 2 |
| P2-06 | R1-E03-T005 | TrialSessionChannel | 2 | 2 |
| P2-07 | R1-E03-T006 | PurgeOldTrialsJob | 2 | 2 |
| P3-01 to P3-10 | R2-E04-T001 to T012 | Payments Epic | 3 | 36 |
| P4-01 | R2-E05-T001 to T010 | Admin Panel Epic | 4 | 35 |
| P4-02 to P4-11 | R2-E06-T001 to T014 | Paid Product Epic | 4 | 49 |
| P4.5 (Phase 4.5) | R2-E07-T001 to T012 | Compliance Epic | 4.5 | 41 |
| P5-01 to P5-10 | R3-E08-T001 to T011 | Speed-to-Lead Epic | 5 | 27 |
| P6-01 to P6-11 | R3-E09-T001 to T013 | Analytics Epic | 6 | 37 |

---

## EPIC SUMMARY

| Epic | Title | Sprint(s) | Tickets | Points | Weeks | Critical Tickets |
|------|-------|-----------|---------|--------|-------|------------------|
| **E-001** | Foundations | 1 | 12 | 32 | 2 | T005, T006, T008 (circuit breakers, webhooks, components) |
| **E-002** | Trial Flow | 2-3 | 15 | 52 | 4 | T005, T006, T007, T010 (Vapi integration, controllers) |
| **E-003** | Mini-Report | 4-5 | 12 | 41 | 4 | T003, T007, T010 (webhook processing, CallCard, mobile) |
| **E-004** | Payments | 6-7 | 12 | 36 | 4 | T004, T006, T009 (Stripe webhooks, conversion, idempotency) |
| **E-005** | Admin Panel | 8 | 10 | 35 | 2 | T002, T003, T004 (webhook inspector, reprocessing, search) |
| **E-006** | Paid Product | 9-10 | 14 | 49 | 4 | T003, T005, T006 (Twilio, webhooks, dashboard) |
| **E-007** | Compliance | 9-10 | 11 | 41 | 4 | T002, T003, T006, T011 (timezone, quiet hours, CallPermission, tests) |
| **E-008** | Speed-to-Lead | 11-12 | 11 | 27 | 4 | T002, T003, T005, T009 (Upsert, job, form, linking) |
| **E-009** | Analytics | 13-14 | 13 | 37 | 4 | T002, T003, T006, T008 (computer, ingest, email, performance) |
| **OPS** | Operational | Throughout | 20 | - | - | OPS-001, OPS-002 (alerts, runbooks) |

**Total MVP Scope:** 130 tickets, ~350 points, 30 weeks (solo) | 18-22 weeks (senior team)

---

## DEPENDENCY CHAINS

### Critical Path (Blocks Everything)
```
V-GATE (validation decision)
  ↓
R1-E01-T001 (Rails scaffold)
  ↓
R1-E01-T007 (Design tokens) → R1-E01-T008 (ViewComponents) → ALL UI TICKETS
  ↓
R1-E01-T005 (Circuit breakers) → ALL API CLIENT TICKETS
  ↓
R1-E01-T006 (Webhook framework) → ALL WEBHOOK TICKETS
```

### Phase Dependencies
```
Phase 0 (E-001) 
  ↓
Phase 1 (E-002) 
  ↓
Phase 2 (E-003) ← CONVERSION MOMENT
  ↓
Phase 3 (E-004)
  ↓
Admin (E-005) → Phase 4 (E-006) || Phase 4.5 (E-007) [PARALLEL]
  ↓
Phase 5 (E-008)
  ↓
Phase 6 (E-009)
```

### Parallel Work Opportunities

**Sprints 9-10 (Track A + Track B):**
- **Track A:** E-006 Paid Product (49pts, 14 tickets)
- **Track B:** E-007 Compliance (41pts, 11 tickets)
- **Constraint:** Both MUST ship together before launch

**Design + Backend Split:**
- **Design:** T007-T009 (tokens, components, wireframes) can progress while backend builds
- **Backend:** T001-T006 (infrastructure) blocks everything else

---

## POINTS DISTRIBUTION

### By Epic
- Foundations: 32pts (9%)
- Trial Flow: 52pts (15%)
- Mini-Report: 41pts (12%)
- Payments: 36pts (10%)
- Admin: 35pts (10%)
- Paid Product: 49pts (14%)
- Compliance: 41pts (12%)
- Speed-to-Lead: 27pts (8%)
- Analytics: 37pts (11%)

### By Track
- Backend (jobs, services, models): ~155pts (44%)
- Frontend (UI, components, Stimulus): ~95pts (27%)
- Infrastructure (DB, webhooks, security): ~65pts (19%)
- Operations (monitoring, runbooks, tooling): ~35pts (10%)

### By Priority
- P0 (Critical Path): 72 tickets, ~245pts (70%)
- P1 (Important): 38 tickets, ~75pts (21%)
- P2 (Nice to Have): 20 tickets, ~30pts (9%)

---

## VALIDATION GATES

### V-GATE: Proceed/Pivot (Week 2)
**BLOCKS:** All Phase 1-6 tickets

**Minimum Signal (Proceed):**
- ✅ 5+ positive responses from 100 HVAC emails
- ✅ 1+ completed manual demo
- ✅ Positioning validated (speed-to-lead resonates)

**Strong Signal (Accelerate):**
- ✅ 10+ responses, 5+ trial signups
- ✅ 1+ "Can I pay for this now?"
- ✅ Paid ads generate 1+ lead <$50 CAC

**Weak Signal (Pivot):**
- ❌ <5 responses from 100 emails
- ❌ 0 interest in demo
- ❌ Common objection repeated >5 times
- **Action:** Try different ICP (gym vs HVAC) or pain point before building

### R1-GATE: Trial Working (Week 12)
**BLOCKS:** Phase 3-6 tickets

**Required:**
- ✅ Prospect can signup → build agent → receive call in <60s
- ✅ TTFC ≤10s P95, TTFA ≤20s P95
- ✅ Trial call success rate >85%
- ✅ Mini-report perfect (mobile, real-time, <3s load)

### R2-GATE: First Paid Customer (Week 22)
**BLOCKS:** Public launch

**Required:**
- ✅ Trial converts to Business successfully
- ✅ Admin panel operational (no SSH debugging)
- ✅ Phase 4.5 compliance COMPLETE (DNC, quiet hours, consent)
- ✅ No TCPA violations in testing

---

## QUICK REFERENCE: CRITICAL TICKETS

### Must Ship in Order (Sequential Dependencies)
1. **R1-E01-T001**: Rails scaffold (everything depends on this)
2. **R1-E01-T008**: ViewComponents (all UI depends on this)
3. **R1-E01-T005**: Circuit breakers (all external APIs depend on this)
4. **R1-E01-T006**: Webhook framework (all webhook tickets depend on this)
5. **R1-E03-T003**: ProcessVapiEventJob (mini-report depends on this)
6. **R1-E03-T010**: Mini-report mobile (conversion depends on this)
7. **R2-E04-T006**: ConvertTrialToBusinessJob (monetization depends on this)
8. **R2-E05-T002**: Webhook inspector (operations depend on this)
9. **R2-E07-T002**: PhoneTimezone (TCPA compliance depends on this)
10. **R2-E07-T006**: CallPermission (all outbound depends on this)

### Can Run in Parallel (No Dependencies)
- Design tokens + Infrastructure setup (Sprint 1)
- Trial UI + Trial backend (Sprint 2-3 partial)
- Paid Product + Compliance (Sprints 9-10 FULL PARALLEL)
- Analytics + Speed-to-Lead prep (Sprint 13 partial)

### High-Risk Tickets (Extra Review Required)
- **R1-E01-T005**: Circuit breakers (production stability)
- **R1-E01-T006**: Webhook framework (revenue security)
- **R1-E03-T003**: ProcessVapiEventJob (race conditions)
- **R1-E03-T010**: Mini-report mobile (conversion driver)
- **R2-E04-T006**: ConvertTrialToBusinessJob (duplicate charges)
- **R2-E07-T002**: PhoneTimezone (TCPA violations)
- **R2-E07-T006**: CallPermission (legal liability)
- **R2-E07-T011**: TCPA test suite (compliance proof)

---

## TICKET CREATION WORKFLOW

### For Each Epic

1. **Read epic strategy** in BUILD-GUIDE.md Section 5
2. **Review ticket list** above for that epic
3. **Create detailed tickets** using BUILD-GUIDE.md Section 6 template
4. **Reference start.md** section numbers for each ticket
5. **Add to backlog tool** (Linear/Jira/GitHub Projects)

### Quality Check Before Import

Each ticket must have:
- ✅ Clear title and description
- ✅ Points estimate (1-8, Fibonacci)
- ✅ Priority (P0/P1/P2)
- ✅ Dependencies listed
- ✅ Acceptance criteria (Given/When/Then)
- ✅ Test approach (which specs first)
- ✅ References to source docs
- ✅ Gotchas/pitfalls specific to ticket

### Detailed Specs Available

**Full detailed specifications with code examples:**
- ticket-breakdown.md: T001-T006 (Foundations)
- BUILD-GUIDE.md: Section 6 (3 detailed examples)
- start.md: Phase sections (inline ticket specs)

**To get detailed spec for any ticket:**
1. Check ticket-breakdown.md first
2. Then BUILD-GUIDE.md epic strategies
3. Then start.md phase sections
4. All follow same template structure

---

## APPENDIX: TICKET NAMING CONVENTIONS

### Why This Format?

**R[Release]-E[Epic]-T[Number]** provides:
- **R1** = Release context (MVP vs future)
- **E01** = Epic grouping (easier to filter in backlog)
- **T001** = Sequential number (sortable)

### Alternative Formats Considered

**From start.md:** P1-01, P2-01 (phase-based)
- ❌ Problem: Phases merge (Phase 4 + 4.5), unclear epic boundaries

**From BUILD-GUIDE.md:** T0-01, T1-01 (ticket-based)
- ❌ Problem: Doesn't indicate epic, hard to filter

**From ticket-breakdown.md:** R1-E01-T001 (chosen format)
- ✅ Advantage: Clear hierarchy, filterable, scales to R2 (post-MVP)

---

## NEXT STEPS

### Week 0-2 (Now)
1. ✅ Review this ticket list with team
2. ✅ Set up backlog tool (Linear/Jira/GitHub Projects)
3. ✅ Execute Sprint 0 (V-001 to V-GATE)
4. ✅ Make proceed/pivot decision

### Week 3 (If V-GATE Pass)
1. Create detailed tickets for E-001 using ticket-breakdown.md format
2. Set up development environments (see OPS-018 to OPS-020)
3. Begin Sprint 1 (Foundations)
4. Establish CI/CD pipeline

### Week 12 (R1-GATE)
1. Review trial conversion metrics
2. Decide: optimize trial OR proceed to payments
3. If proceeding, create detailed tickets for E-004 (Payments)

### Week 22 (R2-GATE)
1. Verify first paid customer working
2. Compliance audit (TCPA checklist)
3. Operational runbooks tested
4. Decision: expand to secondary ICP (gym/dental) or optimize

---

**Document Owner:** Engineering Lead  
**Maintained By:** Product + Engineering  
**Update Cadence:** Weekly during active development  
**Version:** 1.0 (Initial from start.md + BUILD-GUIDE.md synthesis)

