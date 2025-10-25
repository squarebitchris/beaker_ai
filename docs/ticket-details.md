Awesome—here are the fully-detailed tickets for your Batch 1, formatted per the BUILD-GUIDE template.

---

# V-001: HVAC Prospect Scraping (200 contractors) (Epic: Validation | Points: 0 | Priority: P0)

## Context

Validate demand before engineering investment by building a clean, targeted prospect list for the HVAC ICP. Exit is a CSV ready for outreach.  

## Implementation Hints

* Output: `docs/validation/hvac_prospects.csv` (headers: `name, email, phone, website, city, notes, source`).
* Sources: Yelp API, Google Business profiles, LinkedIn.
* De-duplicate by normalized email/phone. Add a “source” column for traceability. 

## Acceptance Criteria (Gherkin)

GIVEN I run the scraping/collection workflow
WHEN I open `docs/validation/hvac_prospects.csv`
THEN it contains ≥200 HVAC contractors with columns (name, email, phone, website, city) and no duplicate emails/phones.

## How to Test (TDD)

* N/A (validation activity). Quick script sanity checks (row count, required columns) are acceptable.

## Common Gotchas

* Low-quality emails (info@/support@). Flag as “generic” for sequence B testing.

## Reference

* start.md §10.6 Validation; TICKET-LIST “Sprint 0: Pre-Launch Validation.” 

## Definition of Done

* [ ] CSV saved, reviewed, and linked in your backlog card.
* [ ] Top 200 rows verified manually (spot check 10%).

---

# V-002: Email Campaign Execution (100 emails) (Epic: Validation | Points: 0 | Priority: P0)

## Context

Send 100 personalized cold emails (≈10/day) to validate messaging and generate demos before writing Phase 1 code. Track opens/replies/sentiment.  

## Implementation Hints

* Template: use Campaign 1 from start.md; mail via SendGrid.
* Sheet: `docs/validation/hvac_outreach_log.csv` with columns (`prospect_id, sent_at, opened, replied, sentiment, next_step`). 

## Acceptance Criteria

GIVEN the 100-row prospect slice
WHEN emails are sent
THEN the log captures at least `sent_at` for all 100 and `opened/replied/sentiment` when observed.

## How to Test

* Validate SendGrid dashboard counts match the log.

## Common Gotchas

* Throttling: keep to ~10/day to keep variants learnable and avoid domain warm-up issues.

## Reference

* TICKET-LIST Sprint 0 details. 

## Definition of Done

* [ ] 100 emails sent and logged.
* [ ] Summary written (opens, replies, themes).

---

# V-003: Manual Demo with Prospects (3+ attempts) (Epic: Validation | Points: 0 | Priority: P0)

## Context

Hands-on demos validate the core “speed-to-lead AI caller” value prop with real prospects before investing in buildout. 

## Implementation Hints

* Use a manually configured Vapi assistant for the demo flow.
* Record a Loom walkthrough to standardize the pitch. 

## Acceptance Criteria

GIVEN at least 3 demo attempts are scheduled
WHEN sessions complete
THEN there is ≥1 completed live demo with notes on feedback and willingness-to-pay.

## How to Test

* Keep a demo notes doc in `docs/validation/demo_notes.md`.

## Common Gotchas

* Ensure demo prospects are from the target ICP (HVAC); otherwise learning is noisy.

## Reference

* TICKET-LIST “Manual Demos.” 

## Definition of Done

* [ ] 3+ attempts, ≥1 completed demo.
* [ ] Notes captured with decision signals.

---

# V-GATE: Decision Point (Proceed/Pivot/Iterate) (Epic: Validation | Points: 0 | Priority: P0)

## Context

Gate to decide whether to proceed to engineering (Phase 1) or pivot messaging/ICP. This **blocks** Phase 1 work. 

## Acceptance Criteria

GIVEN outreach + demos are completed
WHEN we evaluate signals
THEN decision is:

* Proceed if ≥5 positive responses and ≥1 demo,
* Accelerate if ≥10 responses and 3+ “I’d pay,”
* Pivot if <5 responses (try new ICP/pain).  

## Definition of Done

* [ ] Decision recorded and communicated; if proceed, unlock E-001 ticketing. 

---

# T0-01 (alias R1-E01-T001): Rails scaffold + essential gems (Epic: E-001 Foundations | Points: 2 | Priority: P0)

## Context

Create a production-grade Rails skeleton with Postgres UUIDs, Tailwind, RSpec; bin/setup seeds; baseline for all work. 

## Implementation Hints

* `rails new` with Postgres + Tailwind; add RSpec; wire `bin/setup` to create DB + run seeds.
* Ensure app boots, DB connects, Tailwind compiles. 

## Acceptance Criteria

GIVEN a fresh clone
WHEN `bin/setup` then `bin/dev` run
THEN server boots, DB connects, Tailwind builds, and a smoke test passes.

## How to Test (TDD)

* Add a health-check request spec. Keep tests <2 min total per Quality Standards. 

## Common Gotchas

* Missing Postgres UUID default; missing `.env.example`.

## Reference

* BUILD-GUIDE E-001 breakdown. 

## Definition of Done

* [ ] Boot + compile verified locally and in CI. 

---

# T0-02 (alias R1-E01-T002): Magic-link authentication (Devise passwordless) (Epic: E-001 Foundations | Points: 5 | Priority: P0)

## Context

Enable frictionless signup/login to support trial flow and lifecycle messaging. 

## Implementation Hints

* Add Devise with passwordless module; User model modules; magic-link mailer; 20-minute expiry.
* Persist session; ensure links are single-use. 

## Acceptance Criteria

GIVEN a user enters email
WHEN requesting a login link
THEN an email is sent; clicking once logs in and marks token as used; expired tokens are rejected.

## How to Test (TDD)

* Request spec for auth flow + token expiry; factory for users. 

## Common Gotchas

* Email normalization before uniqueness checks (aligns with Phase 1 patterns). 

## Reference

* BUILD-GUIDE E-001, T0-02 details. 

## Definition of Done

* [ ] Auth request spec passing; email actually delivers via SendGrid in dev. 

---

# T0-03 (alias R1-E01-T005): External API clients + circuit breakers (Epic: E-001 Foundations | Points: 5 | Priority: P0 ⚠️)

## Context

Stability first: Vapi/Twilio/Stripe clients must be wrapped with Stoplight circuit breakers with sane timeouts.  

## Implementation Hints

* Create `ApiClientBase`; implement `VapiClient`, `TwilioClient`, `StripeClient`.
* Configure Stoplight: open after 5 failures, auto-reset; Sentry alert on state change; 5s connect/10s read timeouts.  

## Acceptance Criteria

GIVEN an API repeatedly fails
WHEN 5 consecutive failures occur
THEN the breaker opens, calls short-circuit, and a Sentry alert fires; after cooldown, half-open then closed on success.

## How to Test (TDD)

* Service specs simulating success/failure transitions; VCR cassettes for happy/timeout cases. 

## Common Gotchas

* Missing breaker around background jobs leads to retry storms.

## Reference

* E-001 breakdown; High-risk ticket list. 

## Definition of Done

* [ ] Circuit transitions covered by specs; Sentry receives test alert. 

---

# T0-04 (alias R1-E01-T006): Webhook framework + idempotency (Epic: E-001 Foundations | Points: 5 | Priority: P0 ⚠️)

## Context

Reliable, idempotent webhook ingestion is critical for revenue and call results; unique `(provider, event_id)` enforced. 

## Implementation Hints

* Model: `WebhookEvent` with unique composite index `(provider, event_id)`.
* Controller: base controller pattern per provider; verify signatures.
* Job: `WebhookProcessorJob` transitions `received → processing → completed/failed`. 

## Acceptance Criteria

GIVEN a duplicate webhook event
WHEN it posts again
THEN controller returns 200 but skips reprocessing; only new events enqueue processing; invalid signatures → 401.

## How to Test (TDD)

* Request spec (signature verify, idempotency); job spec (state transitions, retry/backoff); Stripe/Twilio test via CLI/ngrok. 

## Common Gotchas

* Request body can be consumed once; cache it.
* Twilio posts form-encoded; Stripe timestamp window; use provider event_id as idempotency key. 

## Reference

* BUILD-GUIDE patterns + ticket-breakdown gotchas. 

## Definition of Done

* [ ] Unique index exists; duplicate events are idempotent; request + job specs pass; manual Stripe CLI test succeeds. 

---

# T0-05 (alias R1-E01-T010/T011): Security baseline (Rack::Attack, SecureHeaders, Sentry) (Epic: E-001 Foundations | Points: 4 | Priority: P0)

## Context

Apply baseline security controls: throttling, CSP/HSTS, secure cookies, structured logs + error capture. 

## Implementation Hints

* Add Sentry + Lograge initializers; Rack::Attack throttles; SecureHeaders config.
* Confirm headers present and throttles enforce 429 on abuse.  

## Acceptance Criteria

GIVEN abusive requests from a single IP
WHEN threshold is exceeded
THEN requests receive 429; response includes security headers (CSP, HSTS). Sentry receives a forced test error. 

## How to Test (TDD)

* Request spec: throttle; initializer specs (headers); manual Sentry error trigger. 

## Common Gotchas

* Don’t disable CSRF globally (only skip for webhooks). 

## Reference

* BUILD-GUIDE Decisions 3–4 (monitoring/design system). 

## Definition of Done

* [ ] Throttle + headers verified; Sentry DSN set via ENV; CI request spec passes. 

---

# T0-06 (alias R1-E01-T007/T008): Design system (ShadCN tokens + 8 ViewComponents) (Epic: E-001 Foundations | Points: 11 | Priority: P0 ⚠️ CRITICAL)

## Context

Tokenized, accessible primitives power every UI; previews enable visual QA; this is critical path for all front-end tickets.  

## Implementation Hints

* `app/assets/stylesheets/tokens.css` (ShadCN-inspired variables) → map in `tailwind.config.js`.
* Build 8 primitives (Button, Input, Card, Badge, Dialog, Toast, Checkbox, Select) with `ViewComponent::Preview`.
* Follow accessibility baseline (keyboard, focus visible).  

## Acceptance Criteria

GIVEN the component gallery
WHEN I open each primitive preview
THEN each renders variants, passes axe checks, and meets mobile (375px, ≥44px touch targets).  

## How to Test (TDD)

* Component specs for props/variants; system spec with axe matcher at AA level. 

## Common Gotchas

* Skipping `ViewComponent::Preview` removes visual QA; don’t ship without it. 

## Reference

* DESIGN decision + token mapping guidance. 

## Definition of Done

* [ ] 8 primitives complete with previews; axe-clean; mobile checked at 375px; tokens power styles (no raw hex). 

---

Great—here are the detailed tickets for your batch, formatted per the Build Guide.

---

# R1-E02-T001: Trial models + migrations (TrialSession, ScenarioTemplate, EmailSubscription) (Epic: E-002 | Points: 3 | Priority: P0)

## Context

Create the core data structures for the trial flow so we can persist scenario templates and each user’s one-off trial session. Include an `email_subscriptions` table for marketing consent captured at signup.  

## Implementation Hints

* **Migrations / Tables**

  * `scenario_templates` (UUID PK): `key` (string, idx), `version` (int), `active` (bool), `prompt_pack` (jsonb), `notes` (text), timestamps. Unique partial index on `(key) WHERE active = true` to enforce one active per key.
  * `trial_sessions` (UUID PK): `user_id` (uuid, FK), `scenario_template_id` (uuid, FK), `persona_params` (jsonb), `kb_payload` (jsonb), `vapi_assistant_id` (string, null), `status` (enum/string: pending|ready|expired|failed), `calls_used` (int, default 0), `ready_at` (datetime), `expires_at` (datetime), timestamps. Indexes on `user_id`, `status`, `ready_at`.
  * `email_subscriptions` (UUID PK): `email` (citext), `marketing_consent` (boolean), `source` (string, default 'trial_signup'), `subscribed_at` (datetime), timestamps. Unique index on `LOWER(email)`.
* **Models**: `ScenarioTemplate`, `TrialSession`, `EmailSubscription` with validations & associations.
* **Generators/Factories**: FactoryBot for all three models; basic scopes (`ScenarioTemplate.active`, `TrialSession.ready`).
* **UUID PKs** enforced in app config (already in Phase 0).
  Refs: ticket list + template guidance.  

## Acceptance Criteria (Gherkin)

```
GIVEN migrations are run
WHEN I insert an active ScenarioTemplate with key "hvac_lead_intake"
THEN a second active template with the same key is rejected by DB uniqueness

GIVEN a TrialSession referencing a valid ScenarioTemplate
WHEN I save without vapi_assistant_id
THEN status defaults to "pending" and calls_used = 0

GIVEN an EmailSubscription is created via signup
WHEN the same email is inserted with different case or +suffix
THEN the unique index prevents duplicates (normalized to lowercase)
```

## How to Test (TDD)

* **Model specs**: validations, associations, scopes.
* **Migration/schema spec**: presence of indexes/constraints.
* **Factories**: build/valid examples for future tickets.
* **Bullet**: ensure no N+1 in simple `includes` loads.

## Common Gotchas

* Don’t enforce “one active per key” in Ruby only—use a **partial unique index**.
* Use `citext` for emails to avoid case-sensitivity surprises.

## Reference

* Build Guide (E-002 Sprint 1 breakdown). 
* Ticket list mapping to Phase 1 migrations. 

## Definition of Done

* [ ] All acceptance tests pass
* [ ] Factories in place
* [ ] Indexes verified in schema dump
* [ ] CI green
* [ ] References added to docs

---

# R1-E02-T002: Seed HVAC scenario template (lead_intake only) (Epic: E-002 | Points: 2 | Priority: P0)

## Context

Provide an initial `ScenarioTemplate` for HVAC lead intake so the PromptBuilder can merge a persona into a working prompt set. 

## Implementation Hints

* Add to `db/seeds.rb`: create `ScenarioTemplate` with `key: "hvac_lead_intake"`, `version: 1`, `active: true`, and a minimal `prompt_pack` JSON (keys: `system`, `first_message`, `tools`).
* Include RSpec seed spec asserting template presence & JSON shape.

## Acceptance Criteria

```
GIVEN a clean database
WHEN I run `rails db:seed`
THEN one active "hvac_lead_intake" ScenarioTemplate (version 1) exists with prompt_pack JSON present
```

## How to Test (TDD)

* `spec/seeds_spec.rb` verifying the record and keys within `prompt_pack`.

## Common Gotchas

* Ensure the seed is idempotent (`find_or_create_by!` + update if needed).

## Reference

* Ticket list entry & Build Guide reference.  

## Definition of Do ne

* [ ] Seed runs cleanly twice
* [ ] Spec passes
* [ ] Template visible in Rails console

---

# R1-E02-T003: PromptBuilder service (merge template + persona) (Epic: E-002 | Points: 2 | Priority: P0)

## Context

Generate the final prompt bundle (`{ system, first_message, tools }`) by merging the active scenario template with user-supplied persona vars (and later a small KB). 

## Implementation Hints

* New service: `app/services/prompt_builder.rb`

  * `#call(template:, persona:, kb: {}) → {system:, first_message:, tools:}`
  * Deep-merge with precedence: template < kb < persona.
  * Placeholder substitution (`{{business_name}}`, etc.).
* Prepare fixtures for a template and persona to keep specs deterministic.

## Acceptance Criteria

```
GIVEN a ScenarioTemplate with placeholders
AND persona values for those placeholders
WHEN PromptBuilder.call is invoked
THEN it returns system/first_message/tools with all placeholders resolved
AND returns a Hash suitable for CreateTrialAssistantJob
```

## How to Test (TDD)

* **Unit spec** for merge precedence + placeholder replacement.
* Include a case with missing persona keys (fallback to template defaults).

## Common Gotchas

* Avoid mutating inputs—use deep dup before merge.
* Keep the output under size limits for downstream APIs (future guard).

## Reference

* Ticket list & Build Guide.  

## Definition of Done

* [ ] Unit spec covers precedence and missing keys
* [ ] Output shape matches job needs
* [ ] CI green

---

# R1-E02-T006: CreateTrialAssistantJob (calls Vapi, sets assistant_id) (Epic: E-002 | Points: 3 | Priority: P0)

## Context

Background job that assembles the prompt (via PromptBuilder), optionally fetches a small KB, and creates a Vapi assistant—persisting `vapi_assistant_id` on the `TrialSession`.  

## Implementation Hints

* `app/jobs/create_trial_assistant_job.rb`

  * Load `TrialSession` by id; bail if status != `pending` or expired.
  * `PromptBuilder.call(template:, persona:, kb:)`
  * `VapiClient.create_assistant(...)` (circuit breaker from Phase 0).
  * Persist `vapi_assistant_id`; transition status → `ready` on success.
* Idempotency: if an assistant already exists, do not create again.

## Acceptance Criteria

```
GIVEN a pending TrialSession with persona and template
WHEN the job runs successfully
THEN vapi_assistant_id is set and status becomes "ready"

GIVEN a transient Vapi error
WHEN the job runs
THEN it retries with backoff and eventually marks failed after max attempts
```

## How to Test (TDD)

* **Job spec** with VCR cassettes (success, timeout, 5xx) and retry behavior.
* Ensure the job is idempotent (re-run on same session does not duplicate).

## Common Gotchas

* Record VCR **before** CI to avoid failures.
* Use circuit breaker defaults (Stoplight) from Foundations.

## Reference

* Ticket list + pitfalls section.  

## Definition of Done

* [ ] VCR specs pass in CI
* [ ] Idempotency verified
* [ ] Status transitions covered

---

# R1-E02-T007: StartTrialCallJob (outbound with caps/quiet hours) (Epic: E-002 | Points: 3 | Priority: P0)

## Context

Kick off the trial’s outbound phone call with hard caps and quiet-hours enforcement to reduce abuse and liability. Must be race-safe and consent-aware.  

## Implementation Hints

* `app/jobs/start_trial_call_job.rb`

  * Load `TrialSession` with `with_lock` and increment `calls_used`.
  * Enforce caps (e.g., max 1–2 attempts per trial) and quiet hours (Phase 1: 8am–9pm business local time via `QuietHours.allow?`).
  * Check consent flags (email + phone).
  * Call `VapiClient.outbound_call(assistant_id, e164_phone)`.
  * Persist call attempt metadata (consider lightweight `trial_call_attempts` table if needed later).

## Acceptance Criteria

```
GIVEN a ready TrialSession within allowed hours and under caps
WHEN the job runs
THEN an outbound call is initiated and calls_used increments atomically

GIVEN quiet hours or caps exceeded
WHEN the job runs
THEN no call is made and a meaningful error state is returned/logged
```

## How to Test (TDD)

* **Job spec** covering: allowed vs blocked hours (time travel), caps enforcement, consent missing, race on `calls_used` (simulate 2 threads).
* Mock Vapi; assert no call when blocked.

## Common Gotchas

* **Must** use `with_lock` to prevent double-dial races.
* Include explicit tests for quiet hours; this is a compliance risk.

## Reference

* Build Guide pitfalls & ticket list.  

## Definition of Done

* [ ] Caps & quiet-hours tests pass
* [ ] Race condition test passes
* [ ] CI green

---

# R1-E02-T009: SignupsController (email + marketing consent) (Epic: E-002 | Points: 3 | Priority: P0)

## Context

Capture an email and marketing consent, create `EmailSubscription`, and initiate the magic-link flow (from Phase 0). This is the entry to the Trial builder.  

## Implementation Hints

* Controller: `app/controllers/signups_controller.rb`

  * `new` (email form), `create` (persist + trigger magic link).
  * Normalize email (use `EmailNormalizer`, below).
  * Create `EmailSubscription` with `marketing_consent: true/false`.
  * On success, redirect to magic-link confirmation page.
* Views: simple, mobile-first form (label, input, consent checkbox).

## Acceptance Criteria

```
GIVEN a prospect submits the signup form with consent checked
WHEN create succeeds
THEN an EmailSubscription record exists and a magic link email is queued
```

## How to Test (TDD)

* **Request spec**: happy path + invalid email + declined consent.
* **Mailer spec**: magic link enqueued (Phase 0 wiring).
* **Service spec**: email normalization behavior (shared with T012).

## Common Gotchas

* Normalize email **before** uniqueness check.
* Don’t block on sending the email—enqueue the mailer.

## Reference

* Build Guide sprint plan; mapping table.  

## Definition of Done

* [ ] Request specs passing
* [ ] Mailer enqueued
* [ ] Mobile form verified at 375px

---

# R1-E02-T010: TrialSessionsController (new/create/show with polling) (Epic: E-002 | Points: 5 | Priority: P0)

## Context

Own the Trial flow lifecycle: render the builder (`new`), create the `TrialSession` and enqueue `CreateTrialAssistantJob` (`create`), and poll readiness (`show`). Also provide `call` action to trigger `StartTrialCallJob` when ready. 

## Implementation Hints

* `app/controllers/trial_sessions_controller.rb`

  * `new`: renders persona form (see T011).
  * `create`: persist `TrialSession`, enqueue `CreateTrialAssistantJob`.
  * `show`: poll `?ready=1` → returns JSON `{ready:boolean}`; when ready, show phone input & consent.
  * `call`: server action to enqueue `StartTrialCallJob` (enforce caps/consent).
* Add minimal routes; require auth (magic link).

## Acceptance Criteria

```
GIVEN an authenticated user builds a trial
WHEN POST /trial_sessions with persona params
THEN a TrialSession is created and CreateTrialAssistantJob is enqueued

GIVEN the assistant becomes ready
WHEN GET /trial_sessions/:id?ready=1
THEN JSON { ready: true } is returned and the UI reveals phone + consent

GIVEN the user taps "Call me"
WHEN POST /trial_sessions/:id/call
THEN StartTrialCallJob enqueues if caps/consent/hours allow
```

## How to Test (TDD)

* **Request specs** for all actions + polling contract.
* **System spec** for E2E happy path (new → create → ready → call).

## Common Gotchas

* Polling must be lightweight and cache-friendly.
* Guard all mutating actions behind auth.

## Reference

* Ticket list controller spec hints. 

## Definition of Done

* [ ] Request + system specs passing
* [ ] Polling returns stable JSON contract
* [ ] CI green

---

# R1-E02-T011: Trial builder UI (persona form, mobile-first) (Epic: E-002 | Points: 3 | Priority: P0)

## Context

Implement the persona form UI (voice, style, scenario pick) optimized for mobile. This feeds `TrialSessionsController#create`. 

## Implementation Hints

* Views: `app/views/trial_sessions/new.html.erb` + progressive enhancement JS (`form_submit_controller.js`).
* Use existing design tokens + ViewComponents from Phase 0.
* Loading/disabled states on submit; client-side constraints only as hints.

## Acceptance Criteria

```
GIVEN a 375px viewport
WHEN I load the trial builder
THEN the form is vertically stacked, touch targets ≥44px, no horizontal scroll
```

## How to Test (TDD)

* **System spec** for layout at 375px.
* **Component specs** for any form components (if using ViewComponents).
* Enforce mobile requirements from the Build Guide.

## Common Gotchas

* Ensure input heights ≥48px and base text ≥16px to prevent iOS zoom.

## Reference

* Mobile requirements in Build Guide. 

## Definition of Done

* [ ] System spec at 375px passes
* [ ] A11y basic checks (labels, focus order)
* [ ] CI green

---

# R1-E02-T012: Email normalization + IP throttling (Rack::Attack) (Epic: E-002 | Points: 3 | Priority: P0)

## Context

Prevent trial abuse by normalizing emails before de-dupe and throttling requests per IP. Applies to signup + session creation. 

## Implementation Hints

* `app/services/email_normalizer.rb`:

  * Lowercase, strip, Gmail dot-collapse and `+tag` removal; return canonical.
* `config/initializers/rack_attack.rb`:

  * Throttle: **10 requests / 10 minutes / IP** on signup + create; return 429 on burst.
  * Allowlist health and internal IPs as needed.
* Wire Normalizer into SignupsController + TrialSessionsController.

## Acceptance Criteria

```
GIVEN gmail-style variants (dots/+tag)
WHEN normalized
THEN the canonical email matches and duplicate signups are prevented

GIVEN >10 create attempts from one IP within 10 minutes
WHEN requests exceed the limit
THEN the endpoint responds 429 with a generic throttle message
```

## How to Test (TDD)

* **Service spec** for normalization cases.
* **Request spec** asserting 429 after threshold, 200 before.

## Common Gotchas

* Normalize **before** any uniqueness checks.
* Ensure throttle keys are specific to sensitive endpoints.

## Reference

* Ticket list entries + mobile/abuse notes.  

## Definition of Done

* [ ] Normalizer unit tests green
* [ ] Throttle request spec green
* [ ] CI green

---

# Cross-Ticket Test Order (per Build Guide)

1. Write **job specs first**: T006, T007 → implement → record VCR. 
2. Then **controller request specs**: T009, T010. 
3. Finally **UI/system**: T011 (+ ready/poll in T010). 

---

Awesome — here are execution-ready ticket details for your Batch 2. I’m following the Build Guide structure (goal → scope → plan → acceptance → tests → ops) and keeping estimates in points.

---

### T1-10 — TrialReaperJob (expire old assistants)

**Goal**
Automatically expire & clean up trial assistants that have passed their TTL or are inactive, and mark their TrialSessions accordingly to control cost and avoid orphaned Vapi resources.

**Scope**

* Scan `TrialSession` records with `assistant_id` where `status IN ('active','ready')` and (`expires_at < now` OR `last_activity_at < now - REAPER_INACTIVITY_WINDOW`)
* Delete/disable associated Vapi assistant (API call), stop any in-progress calls, null-out assistant tokens if required
* Update `trial_sessions.status` → `expired`, set `expired_at`
* Emit audit log + analytics event `trial.reaped` (props: session_id, reason, age_hours, vapi_result)

**Non-Goals**

* Purging historical rows (covered by T2-09)
* UI messaging beyond status already shown

**Data Model / Indexes**

* Add columns to `trial_sessions`: `expires_at:datetime`, `last_activity_at:datetime`, `expired_at:datetime`
* Index: `index_trial_sessions_on_expires_last_activity` (btree on `expires_at`, `last_activity_at`)

**Implementation Plan**

* `TrialReaperJob` (queue: `maintenance`)

  * Batch query (e.g., 500 at a time) with `find_each`
  * For each session: call `VapiClient.disable_assistant!(assistant_id)` (rescue + tag error)
  * Update status & timestamps in a single `update_columns` call
  * Emit `Analytics.track('trial.reaped', …)` and `Rails.logger.info`
* Schedule via cron (e.g., every 15 min) using clock process (Sidekiq-Cron or Que)
* Idempotency: skip if `status == 'expired'` or `assistant_id.nil?`

**Acceptance Criteria**

* Assistants older than TTL are disabled within one schedule cycle
* Matching TrialSessions are set to `expired` and no further outbound calls occur
* Errors are retried up to 10 times with exponential backoff, with dead-letter tagging

**Test Plan**

* Unit: session selection scopes; idempotency; timestamp transitions
* Integration: stub Vapi; verify disable called; analytics event emitted
* Failure: Vapi 5xx → retries; 4xx → mark `expired` but include `reaper_error` meta

**Ops / Metrics**

* Dashboard: count of expired per day; errors by reason; average age at reap
* Alert on >5% Vapi disable failures in a 1-hour window

**Estimate**: 3 pts

---

### T2-01 — Webhook models (WebhookEvent, TrialCall) + migrations

**Goal**
Persist incoming Vapi webhooks and normalized call records to enable reliable processing, replay, analytics, and UI.

**Scope**

* Create `webhook_events` + `trial_calls` tables
* Store raw payloads and processing outcomes (received → processed/failed)
* Normalized `TrialCall` with links to `TrialSession`

**Data Model**

* `webhook_events`

  * `id:uuid` (pk), `source:string` (e.g., 'vapi'), `request_id:string` (unique), `event_type:string`, `signature:string`, `payload:jsonb`, `received_at:datetime` (default now), `processed_at:datetime`, `status:string` (enum: received, processed, failed), `error:text`
  * Indexes: unique(`request_id`), btree(`status`,`received_at`), gin(`payload`)
* `trial_calls`

  * `id:uuid`, `trial_session_id:uuid` (fk), `external_call_id:string` (unique), `direction:string` (enum: outbound,inbound), `status:string` (enum: initiated, ringing, in_progress, completed, failed, no_answer, canceled), `started_at`, `ended_at`, `duration_sec:int`, `recording_url:text`, `transcript:text`, `intent:string`, `lead_json:jsonb`, `meta:jsonb`
  * Indexes: unique(`external_call_id`), btree(`trial_session_id`,`status`), gin(`lead_json`)

**Implementation Plan**

* Rails migrations with strict nullability where possible
* Model validations + enum mappings
* `TrialCall` belongs_to `TrialSession` (required)

**Acceptance Criteria**

* Can persist raw webhook and later mark it processed
* Upsert `TrialCall` by `external_call_id` reliably

**Test Plan**

* Migration reversible; model validations; JSONB defaults; unique constraints

**Estimate**: 3 pts

---

### T2-02 — Vapi webhook controller (signature verify, fast ACK)

**Goal**
Receive Vapi webhooks with robust HMAC signature verification, respond quickly (≤100ms) to avoid retries, enqueue async processing.

**Scope**

* `POST /webhooks/vapi`
* Signature verification middleware/service (`VapiSignature.verify!(headers, raw_body)`)
* Immediate `200 OK` after enqueueing `ProcessVapiEventJob`
* Create `WebhookEvent` row (status: received)

**Non-Goals**

* Business parsing (T2-03)

**Implementation Plan**

* Controller uses `request.raw_post` (avoid JSON parse before verifying)
* On valid signature → create `WebhookEvent`, enqueue job with `webhook_event_id`
* On invalid signature → 401 and log
* Idempotency: if `request_id` exists, still 200 but no double enqueue

**Acceptance Criteria**

* Valid signed requests are accepted and queued; invalid are 401
* Controller responds ≤100ms under load (no DB heavy work in path)

**Test Plan**

* Request specs: valid/invalid signature, missing headers, idempotent path
* Security: only HTTPS is supported in env; CSRF disabled for this endpoint

**Estimate**: 2 pts

---

### T2-03 — ProcessVapiEventJob (parse, upsert TrialCall)

**Goal**
Parse Vapi webhook payloads, update `WebhookEvent` status, and upsert normalized `TrialCall` records bound to the correct `TrialSession`.

**Scope**

* Handle event types: `call.started`, `call.ringing`, `call.answered`, `call.ended`, `recording.available`, `transcript.chunk`, `assistant.created/updated`, error events
* Upsert by `external_call_id`
* Attach to `TrialSession` via one of: (a) `assistant_id` lookup on session; (b) custom metadata from Vapi (e.g., `session_token`); (c) phone number mapping

**Implementation Plan**

* `ProcessVapiEventJob.perform(webhook_event_id)`

  * Fetch event; guard on `status != 'received'` to avoid reprocessing
  * Parse payload; route to small handlers per type
  * Upsert `TrialCall` (compute duration on `ended`)
  * Append transcript text (store chunked and collapse for UI every N chars)
  * Update `webhook_events.status` to `processed` or `failed` with `error`
* Idempotency: versioned upserts; optimistic locking not required if using field-level merges

**Acceptance Criteria**

* Multiple webhook events for the same call converge to one `TrialCall` row with accurate status/duration
* Transcript accumulates in order; recording URL attached when available

**Test Plan**

* Unit: parsers for each event type with sample payloads
* Integration: end-to-end from `webhook_event` to `trial_call` updates
* Failure: malformed payloads → event marked failed, retried with backoff

**Estimate**: 5 pts

---

### T2-04 — LeadExtractor + IntentClassifier services

**Goal**
Extract structured lead data (name, phone, email, address) and classify call intent (e.g., “book_appointment”, “quote_request”, “not_interested”) from transcripts/metadata.

**Scope**

* `LeadExtractor.call(transcript:, metadata:) -> {name, phone, email, address, notes}`
* `IntentClassifier.call(transcript:, metadata:) -> intent_label, confidence`
* Heuristic layer (regex + libphonenumber) with optional LLM fallback (feature-flagged)
* Deterministic output schema suitable for `trial_calls.lead_json` and `intent`

**Implementation Plan**

* Regex for phone/email; simple NER for names; address via libpostal (if installed) else pattern heuristics
* Intent rules (keyword/phrase sets) + scorer; optional `OpenAI`/LLM wrapper with guardrails and tests
* Confidence calibration: 0–1; only persist LLM result if confidence ≥ threshold

**Acceptance Criteria**

* Given fixture transcripts, extractor returns correct fields; classifier returns expected labels (F1 ≥ specified target on fixtures)
* Services are pure and testable; no DB access

**Test Plan**

* Golden fixtures; edge cases (multiple phones/emails; “no thanks”; noisy ASR)
* LLM path behind feature flag; mock in tests

**Estimate**: 5 pts

---

### T2-05 — TrialSessionChannel (ActionCable for Turbo Streams)

**Goal**
Real-time updates to the trial view (transcript lines, call status, intent/lead capture) using ActionCable + Turbo Streams.

**Scope**

* `TrialSessionChannel` with `subscribes_to current_user owns trial_session` authorization
* Broadcast events: `call_status_changed`, `transcript_append`, `lead_detected`, `recording_ready`
* Turbo Stream partials for incremental updates

**Implementation Plan**

* Channel: `stream_for(trial_session)`
* Broadcast hooks from T2-03 handlers (after upsert)
* Policies: ensure only session owner can subscribe
* Backfill on connect: send last N transcript lines

**Acceptance Criteria**

* Opening the Trial detail page shows new transcript text within ~1s of webhook processing
* Unauthorized users cannot subscribe

**Test Plan**

* Channel connection tests; policy tests; Turbo partial rendering tests

**Estimate**: 3 pts

---

### T2-06 — CallCard ViewComponent (recording, transcript, captured)

**Goal**
Reusable UI component to display a call: status, duration, recording (if any), transcript, and captured lead/intent chips.

**Scope**

* `CallCardComponent` props: `trial_call`, `compact: false`
* Slots/regions: header (status + time), body (transcript w/ collapsible), footer (lead chips + CTA)
* States: loading / in_progress / completed / failed; with/without recording
* Accessibility: keyboard controls; transcript readable by SR

**Implementation Plan**

* ViewComponent + Tailwind; server-rendered; progressive enhancement
* Lazy load recording player; copy-to-clipboard for phone/email
* “Captured” chips when `lead_json` present; intent badge with tooltip

**Acceptance Criteria**

* Component renders for all statuses; no layout shift > 100ms
* Mobile looks good by default (see T2-07 for perf constraints)

**Test Plan**

* Component previews + ViewComponent tests; a11y lints

**Estimate**: 3 pts

---

### T2-07 — Mini-report mobile optimization (<3s load, 60px tap)

**Goal**
Ensure the mini-report view (trial session summary) loads fast on mobile and meets basic touch-target accessibility.

**Scope**

* Target: First Contentful Paint ≤ 1.5s, Time-to-Interactive ≤ 3s on emulated slow 4G; max 60KB critical CSS/JS; images lazy-loaded
* All actionable tap targets ≥ 60px height/width; 16px+ text
* Server-rendered HTML; defer any non-critical JS; cache headers

**Implementation Plan**

* Remove unused JS/CSS; tree-shake; preconnect to CDN; HTTP caching (ETag + max-age)
* Inline critical CSS limited to above-the-fold
* Optimize images (width/height set; `loading="lazy"`; `fetchpriority="low"` for non-critical)
* Add Lighthouse CI job with mobile preset and budgets

**Acceptance Criteria**

* Lighthouse Mobile: Performance ≥ 90; Accessibility ≥ 95; Tap targets pass
* WebPageTest (or lab test) shows TTI ≤ 3s

**Test Plan**

* Automated Lighthouse run in CI; Percy/visual checks for regressions

**Estimate**: 5 pts

---

### T2-08 — Conversion tracking (CTA click monitoring)

**Goal**
Track conversions from the mini-report and call UI CTAs to measure funnel performance.

**Scope**

* Events: `cta.click` (props: `cta_id`, `location`, `trial_session_id`, `call_id`, `utm_*`, `user_id`)
* Server-side event logging + optional client ping for redundancy
* Append UTM to outbound links; support magic-link continuation if applicable

**Implementation Plan**

* `Analytics.track` helper; ensure no PII leakage in URLs
* Hidden form beacon fallback (`<img>`/`<noscript>`)
* Capture referer and device info in server logs (with PII guardrails)
* Dashboard query for CTR per CTA/location

**Acceptance Criteria**

* Each CTA click generates one event with correct context
* Events joinable to TrialSession and, if sign-up occurs, to user account

**Test Plan**

* Request specs to ensure logging without double-counting
* E2E: click CTA → event persisted → visible in query

**Estimate**: 2 pts

---

### T2-09 — PurgeOldTrialsJob (7-day retention)

**Goal**
Delete trial data older than 7 days to control cost and reduce exposure of PII.

**Scope**

* Hard-delete `TrialSession` and dependents (`TrialCall`, `WebhookEvent` rows related) where `created_at < now - 7 days` and `status IN ('expired','completed','failed')`
* Optionally keep minimal aggregate counters for analytics (non-PII)
* Ensure external assets (e.g., recordings) are deleted from storage/Vapi when configured

**Data/Constraints**

* Add FK `ON DELETE CASCADE` where safe; else perform in topological order
* Configurable retention via `ENV['TRIAL_RETENTION_DAYS']` default 7

**Implementation Plan**

* `PurgeOldTrialsJob` (queue: `maintenance`) with batch deletion in transactions
* Call `VapiClient.delete_recording!` where URLs are Vapi-hosted and allowed
* Emit `trial.purged` analytics with counts

**Acceptance Criteria**

* No rows older than retention remain after a daily run
* External recordings for purged trials are not accessible

**Test Plan**

* Unit: selection scope; deletion order; dry-run mode test
* Integration: create graph of related rows; after job, all gone
* Safety: limit clause + measurable backpressure (avoid long locks)

**Ops / Alerts**

* Daily summary log: purged counts, duration, failures
* Alert if job fails 3 consecutive days

**Estimate**: 3 pts

---

## Cross-Ticket Notes & Dependencies

* **Dependencies**:

  * T2-02 → T2-03 → T2-05/T2-06
  * T2-04 consumes transcripts produced by T2-03
  * T2-07 builds on T2-06 layouts
  * T1-10 should run before T2-09 (expire → later purge)

* **Security/Privacy**:

  * Never store raw phone recordings beyond retention; encrypt at rest
  * JSONB payloads in `webhook_events` may contain PII → access via admin role only; redact on export
  * HMAC keys rotated quarterly

* **Observability**:

  * Add structured logs (`event`, `session_id`, `call_id`, `request_id`)
  * SLOs: webhook 2xx rate ≥ 99.9%, median processing latency ≤ 2s

Awesome — here are execution-ready ticket details for this batch, following the Build Guide structure (goal → scope → plan → acceptance → tests → ops). Estimates are in points.

---

### T3-01 — Stripe client + circuit breaker

**Goal**
Provide a safe, testable Stripe client with timeouts, retries, idempotency keys, and a circuit breaker to protect the app from upstream issues.

**Scope**

* `StripeClient` service wrapper around `stripe-ruby` with:

  * Reasonable defaults: connect/read timeouts, 429/5xx retry (jittered backoff).
  * Idempotency keys for mutating calls (create checkout session, customer, etc.).
  * Circuit breaker (e.g., Stoplight/Circuitbox) with half-open probing.
* Structured logging and error taxonomy (rate_limit, timeout, api_error, auth_error).

**Non-Goals**

* Business logic (handled by controllers/jobs).

**Implementation Plan**

* ENV: `STRIPE_API_KEY`, `STRIPE_WEBHOOK_SECRET`, `STRIPE_PRICE_ID_*`.
* `StripeClient` methods: `create_checkout_session(params)`, `retrieve_event(id:)`, `construct_event(payload:, sig:)`, `get_customer(id)`, etc.
* Use `request_id` from Stripe headers in logs; tag all calls.

**Acceptance Criteria**

* When Stripe is slow or down, calls fail fast after timeout; breaker opens after threshold and auto-recovers.
* Idempotent creation: repeated requests with same key do not double-charge.

**Test Plan**

* Unit: retry policy, idempotency, circuit transitions.
* Integration (stubbed): 429/500 → retry; 400 → no retry; verify headers/keys.

**Ops / Metrics**

* Emit counters: successes/failures by method; breaker state.
* Alert if breaker open > 5 minutes.

**Estimate**: 3 pts

---

### T3-02 — Checkout session controller (redirect to Stripe)

**Goal**
Create a secure endpoint to start a paid conversion by redirecting users to Stripe Checkout.

**Scope**

* `POST /checkout/sessions` (authenticated).
* Accepts `price_id` (or server-side mapping to plan), `success_url`, `cancel_url`.
* Creates Stripe Checkout Session with `mode: 'subscription'` (or one-time if needed), `client_reference_id` = `current_user.id`, `metadata` includes `trial_session_id`.

**Implementation Plan**

* Server builds idempotency key: `checkout:<user_id>:<trial_session_id>`.
* Persist a local `CheckoutAttempt` (optional) for auditing.
* Redirect 303 to `session.url` on success; handle/flash on failure.

**Acceptance Criteria**

* Valid request creates one session and redirects.
* Invalid price or unauthenticated returns 403/422 without creating session.

**Test Plan**

* Request specs: happy path; missing params; replay with same idempotency key.
* Verify session metadata carries `trial_session_id`.

**Estimate**: 3 pts

---

### T3-03 — Stripe webhook handler (checkout.session.completed)

**Goal**
Reliably receive and verify Stripe webhooks and trigger post-purchase provisioning.

**Scope**

* `POST /webhooks/stripe`:

  * Verify signature (`StripeClient.construct_event`).
  * Fast ACK (≤100ms) after enqueueing job.
  * Store raw payload using existing `WebhookEvent` (source: `stripe`) for idempotency/replay.
* Handle `checkout.session.completed`:

  * Resolve `user` via `client_reference_id` or `customer_email`.
  * Enqueue `ConvertTrialToBusinessJob` with dedupe key = `session.id`.

**Implementation Plan**

* Idempotency via `WebhookEvent.request_id = event.id` (unique).
* Only minimal parsing in controller; heavy work in job (T3-07 covers races).

**Acceptance Criteria**

* Valid signatures → 200 + job enqueued; invalid → 401.
* Duplicate events do not double-provision.

**Test Plan**

* Request specs: signature valid/invalid, duplicate event, missing fields.
* End-to-end: event → `WebhookEvent` stored → job enqueued.

**Estimate**: 3 pts

---

### T3-04 — ConvertTrialToBusinessJob (clone assistant, create Business)

**Goal**
Convert a paying trial into a full business account: create `Business`, clone the trial Vapi assistant to a durable assistant, migrate minimal configuration, and set ownership.

**Scope**

* Inputs: `user_id`, `trial_session_id`, `stripe_session_id`.
* Steps (transactional where possible):

  1. Ensure idempotency: upsert `ProvisioningRun` keyed by `stripe_session_id` (status: pending|done|failed; error).
  2. Create `Business` (T3-05) owned by `user`.
  3. Clone Vapi assistant (via Vapi client): copy scenario template/persona; set production caps/quiet hours.
  4. Link `Business` to `assistant_id`, `stripe_customer_id`, `stripe_subscription_id` (if present).
  5. Mark `trial_session` as `converted` and lock further trial calls.
  6. Emit events: `purchase.completed`, `business.provisioned`.
  7. Trigger T3-08 email.

**Implementation Plan**

* Robust error handling with compensations (e.g., if Vapi clone fails, roll back `Business`).
* All external calls wrapped in circuit/timeout; retries for transient errors.

**Acceptance Criteria**

* Running the job multiple times for same `stripe_session_id` is no-op.
* After success, user has exactly one `Business` with linked assistant; trial is inactive.

**Test Plan**

* Unit: idempotency; partial failures; Vapi clone mock.
* Integration: happy path creates Business and sets associations.

**Ops / Metrics**

* Provisioning duration p50/p95, failure rate < 1%.
* Alert on 3 consecutive failures for same cause.

**Estimate**: 5 pts

---

### T3-05 — Business model + unique constraints

**Goal**
Introduce `Business` domain entity with strict uniqueness and referential integrity.

**Scope**

* `businesses` table:

  * `id:uuid`, `owner_id:uuid (User)`, `name:string`, `slug:string`, `assistant_id:string`, `stripe_customer_id:string`, `stripe_subscription_id:string`, `plan:string`, `status:string` (active|paused|canceled), `settings:jsonb`, timestamps.
* Constraints & indexes:

  * Unique: `slug`, `assistant_id`, `stripe_customer_id`, `stripe_subscription_id` (nullable uniques).
  * FK: `owner_id` → `users` (index).
  * GIN on `settings`.

**Implementation Plan**

* Model validations: presence `owner_id`, `name`, `slug` (slugified, reserved list).
* Associations: `belongs_to :owner, class_name: 'User'`.

**Acceptance Criteria**

* Cannot create duplicate slug or attach same assistant to multiple businesses.
* Deleting user with business is blocked (or reassigned) per policy.

**Test Plan**

* Model specs for validations/uniques; migration reversible.

**Estimate**: 2 pts

---

### T3-06 — Onboarding shell page (post-purchase redirect)

**Goal**
Provide a friendly, resilient page users land on after Checkout that tracks provisioning and routes them into setup.

**Scope**

* `GET /onboarding/ready?session_id=cs_test_…`
* Poll an endpoint (`/api/onboarding/status?session_id=`) returning {state: pending|ready|failed, business_id, next_path}.
* States:

  * pending: spinner + “Setting up your agent…”
  * ready: redirect to `/business/:id/setup` (hours, number, CTA config).
  * failed: error with support link and retry button.

**Implementation Plan**

* Server renders minimal JS; no SPA required.
* Status reads `ProvisioningRun` (from T3-04).

**Acceptance Criteria**

* With a valid `session_id`, page progresses to ready within the same session after job completes.
* Invalid/unknown `session_id` shows safe error.

**Test Plan**

* Request/feature spec: each visual state; accessibility basics.

**Estimate**: 3 pts

---

### T3-07 — Idempotency testing (concurrent webhooks)

**Goal**
Prove the provisioning flow is safe under concurrent duplicate webhooks and retries.

**Scope**

* Concurrency tests simulating 2–5 simultaneous `checkout.session.completed` events for same `session_id`.
* Ensure only a single `Business` and single Vapi clone occur.

**Implementation Plan**

* RSpec with threads (or `TestProf::EventProf`) + DB transaction isolation.
* Guarded by unique key on `ProvisioningRun(stripe_session_id)` and retry on `ActiveRecord::RecordNotUnique`.

**Acceptance Criteria**

* 100 runs without duplicate businesses or assistants.
* At most one job performs the critical section; others exit as no-ops.

**Test Plan**

* Stress/spec harness committed and runnable in CI.

**Estimate**: 2 pts

---

### T3-08 — Agent-ready email (welcome to paid)

**Goal**
Send a branded “Welcome to Paid” email when provisioning completes, with next steps and deep links.

**Scope**

* Mailer: `BillingMailer#welcome_paid(user, business)` with:

  * Summary of what’s ready (assistant live status).
  * CTAs: “Set hours,” “Connect number,” “Add website CTA,” “Invite teammate.”
  * Unsubscribe footer/compliance.
* Triggered at end of T3-04 on success only.

**Implementation Plan**

* Use transactional email provider; retry on transient failures.
* Template supports dark-mode and mobile.

**Acceptance Criteria**

* Exactly one email per successful conversion.
* Links contain tracking params (see T2-08) without PII leak.

**Test Plan**

* Mailer previews; content tests; delivery stub in job spec.

**Estimate**: 2 pts

---

### T4-01a — Admin authentication + RBAC (user.admin flag)

**Goal**
Create a lightweight admin surface gated by `user.admin` with clear authorization boundaries.

**Scope**

* Add `users.admin:boolean, default: false, null: false`.
* Policy (Pundit/ActionPolicy): only admins can access `/admin/*`.
* Admin base controller + layout; initial pages:

  * WebhookEvents index/show (both Stripe & Vapi).
  * Businesses index/show with impersonation link (if allowed).
* Audit log for admin actions (read/show impersonation events).

**Implementation Plan**

* Add `current_admin?` helper; protect routes with constraint.
* Optional: 2FA gate (future ticket).

**Acceptance Criteria**

* Non-admin cannot access any admin route (403).
* Admin can list/search `WebhookEvents` and `Businesses`.

**Test Plan**

* Policy specs; request specs for access control; audit log creation.

**Ops / Security**

* Hide admin URLs from sitemap; require HTTPS; session timeout shorter for admin.

**Estimate**: 3 pts

---

## Dependencies & Notes

* T3-01 precedes T3-02/T3-03.
* T3-03 feeds T3-04; T3-07 validates both.
* T3-05 must exist before T3-04 completion.
* T3-06 consumes `ProvisioningRun` from T3-04.
* T3-08 triggers off T3-04 success.
* Reuse `WebhookEvent` infra from T2-01 with `source: 'stripe'`.

# T4-01b: Webhook event inspector (Epic: E-005 | Points: 5 | Priority: P0)

## Context

Admin needs to debug webhook/conversion issues without SSH by listing events, drilling into details, and viewing raw JSON with syntax highlighting. Ships first in Phase 4 admin sprint.  

## Implementation Hints

* Controllers/Views:

  * `app/controllers/admin/webhook_events_controller.rb` (`index`, `show`)
  * `app/views/admin/webhook_events/index.html.erb` (paginated table with filters)
  * `app/views/admin/webhook_events/show.html.erb` (pretty JSON, masked PII)
  * Layout: `app/views/layouts/admin.html.erb`
* Model: `WebhookEvent` scopes for `provider`, `status`, `created_at`
* Add JSON viewer (client-side syntax highlight)
* Routes: `namespace :admin do resources :webhook_events, only: [:index, :show] end`
* Pagination (kaminari) and eager loading to avoid N+1
* Admin guard: all Admin::* controllers inherit `Admin::BaseController` (custom admin, no gem). 
* Mask PII in views (emails/phones) per guide. 

## Acceptance Criteria (Gherkin)

GIVEN I am an admin
WHEN I visit `/admin/webhook_events`
THEN I see a paginated list with columns: provider, event_id, status, created_at
AND I can filter by provider and status and search by `event_id`
AND each row links to a detail page.

GIVEN I am on `/admin/webhook_events/:id`
WHEN I view the event
THEN I see a prettified JSON payload with keys/values highlighted
AND PII is masked (emails/phones obfuscated)
AND related processing/job status is shown.

## How to Test (TDD)

* Request specs: non-admin → 404; admin can list/filter/show.
* System spec: navigate to list, filter, open detail, verify JSON viewer.
* Performance: list view renders < 200ms @ 1k records with pagination.
* Seed a few `WebhookEvent` factories with different providers/statuses.

## Common Gotchas

⚠️ Unpaginated lists will crawl beyond ~1k events; use pagination. 
⚠️ Don’t print raw PII in admin; mask emails/phones and scrub logs. 

## Reference

* BUILD-GUIDE: Admin panel strategy, UI files, pitfalls. 
* TICKET-LIST: R2-E05-T002 baseline. 

## Definition of Done

* [ ] Request + system specs passing
* [ ] PII masked, no N+1 (Bullet clean)
* [ ] Admin-only access enforced
* [ ] JSON viewer works on large payloads
* [ ] Linked from admin sidebar

---

# T4-01c: Event reprocessing endpoint (Epic: E-005 | Points: 3 | Priority: P0)

## Context

Admins must safely reprocess failed (or stuck) webhook events with an explicit confirmation; idempotent and auditable. 

## Implementation Hints

* Controller action: `Admin::WebhookEventsController#reprocess` (POST)
* Route: `post '/admin/webhook_events/:id/reprocess'`
* Job: `ReprocessWebhookEventJob` dispatches by `provider` (e.g., Vapi/Stripe)
* UI: confirmation modal before enqueue; flash notice upon enqueue
* Audit trail: log admin user, event id, timestamp
* Follow the reprocessing safety pattern provided. 
* CLI parity (optional): aligns with `webhooks:reprocess_failed` rake. 

## Acceptance Criteria (Gherkin)

GIVEN an admin on `/admin/webhook_events/:id` for a failed event
WHEN they click “Reprocess” and confirm
THEN the event status resets to `received`
AND `ReprocessWebhookEventJob` is enqueued
AND the UI shows “Event queued for reprocessing”.

GIVEN the same event is already `processed`
WHEN reprocessed
THEN the UI warns about idempotency but still enqueues safely.

## How to Test (TDD)

* Request spec: POST requires admin; 404 for non-admin.
* Job spec: job routes to correct processor, resilient to multiple runs.
* System spec: confirmation modal → success flash.
* Concurrency: ensure double-click produces one effective outcome (idempotent).

## Common Gotchas

⚠️ Reprocessing can have side-effects; warn admins in UI. 
⚠️ Always audit admin actions (who/when). 

## Reference

* BUILD-GUIDE: Reprocessing & runbooks. 
* TICKET-LIST: R2-E05-T003 baseline. 

## Definition of Done

* [ ] Request + job + system specs passing
* [ ] Admin-only, confirmation modal, audit event recorded
* [ ] Idempotency verified in specs
* [ ] Flash feedback and error states handled

---

# T4-01d: Entity search (Business/User/Lead by email/phone) (Epic: E-005 | Points: 5 | Priority: P0)

## Context

Admins need a fast way to locate entities (Business/User/Lead) by email/phone/ID during incidents. Autocomplete encouraged; PII masking enforced. 

## Implementation Hints

* Controller: `Admin::SearchController#show` (single endpoint returning results for all 3 types)
* Server-side fuzzy search (ILIKE) with normalization (`phone_e164`)
* Stimulus controller for typeahead/autocomplete in the admin topbar
* Results list shows key fields + quick links (entity detail)
* Mask PII in logs & views
* Performance: paginate >50 results; use `.includes` to avoid N+1

## Acceptance Criteria (Gherkin)

GIVEN I am an admin
WHEN I search “+1 415 555 1234” or “alice@ex…”
THEN I see matching Businesses, Users, Leads in one results view
AND PII is partially masked in the UI and not printed in logs
AND clicking a result opens the entity’s admin detail.

## How to Test (TDD)

* Request spec: ensures normalized phone and email queries match
* Search accuracy spec: edge cases (spaces, hyphens, partial email)
* System spec: autocomplete shows debounced results

## Common Gotchas

⚠️ N+1 from associated lookups—use `includes`. 
⚠️ PII safety in admin views/logs. 

## Reference

* BUILD-GUIDE: Admin sprint breakdown + pitfalls. 
* TICKET-LIST: R2-E05-T004 baseline. 

## Definition of Done

* [ ] Request + system specs passing
* [ ] PII masked, Bullet clean
* [ ] Fast enough for 100k-row datasets with indexes

---

# T4-02: PhoneNumber model + Twilio client (Epic: E-006 | Points: 3 | Priority: P0)

## Context

Provision dedicated phone numbers per Business and manage Twilio via a thin client with circuit breakers. Kicks off Paid Product epic. 

## Implementation Hints

* Migration: `phone_numbers` (uuid PK)

  * `business_id:uuid` (FK), `e164:string` (unique), `twilio_sid:string` (unique)
  * `country:string`, `area_code:string`, `capabilities:jsonb` (default `{}`)
  * Indexes: unique on `e164`, `twilio_sid`; `business_id`
* Model: `PhoneNumber` belongs_to `Business`
* Service: `app/services/twilio_client.rb` with:

  * `buy_local_number(country:, area_code:)` → `{sid, phone_number, capabilities}`
  * `update_number_webhook(sid:, voice_url:)`
  * Wrapped in Stoplight circuit breaker; VCR/WebMock for tests
* ENV: `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_DEFAULT_AREA_CODE`, `VAPI_BRIDGE_VOICE_URL`
* Patterns per guide (client extends `ApiClientBase`). 

## Acceptance Criteria (Gherkin)

GIVEN migrations run
WHEN I instantiate `TwilioClient` and call `buy_local_number`
THEN a Twilio number purchase request is issued (stubbed in tests)
AND a `PhoneNumber` can persist the returned data with unique constraints.

## How to Test (TDD)

* Model spec: validations, associations, unique indexes
* Service spec (VCR/WebMock): success + error cases; circuit breaker opens on failures

## Common Gotchas

⚠️ Don’t hardcode webhooks; make `voice_url` configurable. 
⚠️ Wrap external IO with circuit breakers & handle retries per patterns. 

## Reference

* BUILD-GUIDE sprint breakdown. 
* TICKET-LIST TwilioClient details. 

## Definition of Done

* [ ] Migration + model + client implemented
* [ ] Specs for model + client + breaker behavior
* [ ] ENV documented; secrets not logged

---

# T4-03: AssignTwilioNumberJob (buy number, configure voice URL) (Epic: E-006 | Points: 5 | Priority: P0)

## Context

Assigns a dedicated Twilio number to a Business, configures voice webhook to the Vapi bridge, and persists/associates it. Broadcast dashboard update on success. 

## Implementation Hints

* Job: `AssignTwilioNumberJob.perform_later(business_id:)`

  * Idempotent: if business already has number, no-op
  * Calls `TwilioClient.buy_local_number`, then `update_number_webhook`
  * Creates `PhoneNumber` and sets `Business.phone_number_id`
  * Turbo broadcast to `BusinessChannel`
* VCR fixtures for Twilio purchase + webhook updates
* ENV: area code fallback; voice URL from `VAPI_BRIDGE_VOICE_URL`

## Acceptance Criteria (Gherkin)

GIVEN a Business without a number
WHEN the job runs successfully
THEN a Twilio number is purchased and linked to the Business
AND Twilio voice URL is configured
AND a dashboard broadcast is sent.

## How to Test (TDD)

* Job spec: happy path (with VCR), error path (Twilio failure), idempotency (run twice)
* Verify turbo broadcast enqueued on success

## Common Gotchas

⚠️ Race conditions creating duplicate numbers—use DB uniqueness + guard clause.
⚠️ Ensure failures surface to Sentry with enough context (business_id, area_code).

## Reference

* TICKET-LIST: AssignTwilioNumberJob spec hints. 

## Definition of Done

* [ ] Job + specs + VCR cassettes
* [ ] Broadcast verified
* [ ] Idempotency proven in tests

---

# T4-04: Business dashboard shell (number display, stats) (Epic: E-006 | Points: 3 | Priority: P0)

## Context

Initial dashboard for paid customers showing assigned number, basic KPIs (7d), and recent calls list placeholder; subscribes to Turbo/ActionCable. 

## Implementation Hints

* Controller/View:

  * `BusinessesController#dashboard`
  * `app/views/businesses/dashboard.html.erb`
* Components: KPI tiles (calls/leads last 7 days—use `AnalyticsComputer` MVP counts) 
* Show number or CTA to “Assign number”
* Subscribe to `BusinessChannel` for live updates

## Acceptance Criteria (Gherkin)

GIVEN a Business with a number
WHEN I open the dashboard
THEN I see the E.164 number displayed
AND KPI tiles for Calls/Leads (7d)
AND the page subscribes to real-time updates.

## How to Test (TDD)

* Request spec (authz)
* System spec verifies number display, KPI values, and that ActionCable subscription is present

## Common Gotchas

⚠️ Avoid N+1 on aggregates; precompute counts where needed. 

## Reference

* TICKET-LIST: dashboard shell details. 

## Definition of Done

* [ ] Request + system specs
* [ ] KPI tiles render from service
* [ ] ActionCable subscription active

---

# T4-05: BusinessChannel (ActionCable for live updates) (Epic: E-006 | Points: 2 | Priority: P0)

## Context

Real-time channel for per-business updates (new calls, KPIs). Required by dashboard and call history. 

## Implementation Hints

* Channel: `app/channels/business_channel.rb`

  * `stream_for current_business` after auth check (user owns business)
* Broadcast helpers: `BusinessChannel.broadcast_to(business, payload)`
* Hook broadcasts from `AssignTwilioNumberJob` and call creation

## Acceptance Criteria (Gherkin)

GIVEN a logged-in business user
WHEN the dashboard loads
THEN the client subscribes to `BusinessChannel`
AND receiving a broadcast updates the DOM via Turbo Stream.

## How to Test (TDD)

* Channel spec: rejects unauthenticated/unauthorized, accepts owner
* System spec: simulate broadcast → Turbo updates a placeholder div

## Common Gotchas

⚠️ Don’t leak cross-business data—authorize subscription by ownership.

## Reference

* TICKET-LIST: BusinessChannel scope. 

## Definition of Done

* [ ] Channel + auth checks
* [ ] Tests for authorize/stream/broadcast
* [ ] Example Turbo partial wired

---

# T4-06: Paid Vapi webhook processing (create Call records) (Epic: E-006 | Points: 5 | Priority: P0)

## Context

Extend Vapi webhook processing so paid calls create `Call` (not `TrialCall`), handle race conditions, and broadcast to dashboard. 

## Implementation Hints

* Update `ProcessVapiEventJob`:

  * Add `process_paid(event)` path using `business_id` to upsert `Call`
  * Ensure idempotency via unique `vapi_call_id`
  * After create/update, broadcast to `BusinessChannel`
* Dependency: Calls model exists (R2-E06-T001). 
* Concurrency pattern mirrors Stripe idempotency patterns. 

## Acceptance Criteria (Gherkin)

GIVEN a paid Vapi webhook for an in-progress or completed call
WHEN the job processes it
THEN a `Call` record is created/updated exactly once
AND the business dashboard receives a broadcast.

## How to Test (TDD)

* Job spec: process the same webhook twice → 1 Call record (concurrency test)
* VCR cassette with representative Vapi payload(s)
* Channel broadcast observed in spec

## Common Gotchas

⚠️ Don’t reuse `TrialCall`; ensure paid path writes `Call`.
⚠️ Guard against duplicate webhooks (unique index + rescue on conflict). 

## Reference

* TICKET-LIST: Paid webhook processing. 

## Definition of Done

* [ ] Job updated + specs passing
* [ ] Idempotency verified
* [ ] Broadcast on updates

---

# T4-07: Call history table with real-time updates (Epic: E-006 | Points: 5 | Priority: P0)

## Context

Render recent calls with Turbo-prepend on new webhook events; show key fields and access to recording/transcript. 

## Implementation Hints

* Partial: `app/views/calls/_call.html.erb` (CallCard)
* List: `app/views/calls/index.html.erb` or embed as partial on dashboard
* Turbo Stream from `BusinessChannel` to prepend new calls
* Columns: started_at, direction, caller_phone, duration, intent, status, links to recording/transcript

## Acceptance Criteria (Gherkin)

GIVEN existing calls
WHEN I open the dashboard
THEN I see a list of recent calls (most recent first).

GIVEN a new call webhook is processed
WHEN the broadcast fires
THEN the new call appears at the top without a full page reload.

## How to Test (TDD)

* System spec: seed N calls, load page, simulate broadcast → Turbo prepend
* View spec: renders required columns and links

## Common Gotchas

⚠️ Keep rows lightweight; lazy-load long transcripts.
⚠️ Verify Turbo stream targets are stable (DOM ids consistent).

## Reference

* TICKET-LIST: call history real-time behavior. 

## Definition of Done

* [ ] System spec proves real-time prepend
* [ ] View specs pass; a11y basic checks
* [ ] No N+1 on calls list

---

# T4-08: Recording player in dashboard (reuse from mini-report) (Epic: E-006 | Points: 2 | Priority: P0)

## Context

Embed audio player for call recordings within dashboard call rows/details by reusing the existing mini-report player and accessibility patterns.  

## Implementation Hints

* Reuse component/partial from mini-report (keyboard-accessible controls)
* In `calls/_call.html.erb`, show play button if recording_url present
* Lazy-load audio elements to avoid heavy initial page weight

## Acceptance Criteria (Gherkin)

GIVEN a call with a `recording_url`
WHEN I click the play button
THEN audio plays with visible controls
AND keyboard shortcuts work (space to play/pause).

## How to Test (TDD)

* View/component spec: renders player when `recording_url` present
* System spec: basic keyboard interaction works (tab/space)

## Common Gotchas

⚠️ Don’t auto-load/auto-play all audio; load on interaction.
⚠️ Keep player accessible (labels, focus states). 

## Reference

* BUILD-GUIDE: mini-report/audio a11y emphasis. 

## Definition of Done

* [ ] Reused component wired
* [ ] a11y checks pass
* [ ] Works across recent Chrome/Safari/Firefox

---

## Dependencies & Ordering

* Admin tickets (T4-01b/c/d) depend on `T4-01a: Admin authentication + RBAC` being merged. 
* Paid product tickets:

  * T4-02 precedes T4-03 (client before job). 
  * T4-03 precedes T4-04 (dashboard shows assigned number).
  * T4-04/05 precede T4-06/07/08 (channel + shell before real-time/history/player). 

yes — here are the Phase 4.5 compliance tickets, fully detailed and ready to drop into your tracker.

---

# T4.5-01 — Compliance models (ConsentRecord, DncNumber, AuditLog)

**Epic:** E-007 Compliance • **Priority:** P0 • **Points:** 3

## Context

Phase 4.5 introduces enforceable guardrails. We need first-class tables to persist consent, do-not-call entries, and an auditable trail of all compliance-sensitive actions. These tables are explicitly called out as part of the Phase 4.5 data model. 

## Scope & Implementation

* **Migrations**

  * `consents` (uuid PK): `user_id`, `business_id`, `subject_type`, `subject_id`, `channel`, `purpose`, `opt_in`, `statement`, `ip`, `user_agent`, `consented_at` (+ composite indexes as needed). 
  * `dnc_numbers` (uuid PK): `business_id`, `phone_e164` (unique per business), `source`, `note`, timestamps. (DNC list is a named artifact in 4.5.) 
  * `audit_logs` (uuid PK): `actor_type/id`, `event`, `metadata:jsonb`, `created_at`. (Used across compliance changes/denials.) 
* **Model validations**

  * `DncNumber`: unique `[business_id, phone_e164]`; normalize phone on write.
  * `Consent`: presence of `channel`, `purpose`, snapshot `statement`, and `consented_at`.
* **Seeds:** None required; factories for specs.

## Acceptance Criteria

* Running migrations creates all three tables with indexes/FKs, matching Phase 4.5 data model. 
* `DncNumber` rejects duplicates for the same business; phone normalized to E.164.
* `AuditLog` writes succeed with arbitrary JSON metadata.

## Tests (TDD)

* Migration/schema specs for tables + constraints. 
* Model specs: `DncNumber` uniqueness/normalization; `Consent` required fields.

## Gotchas

* Mask PII in logs when rendering model instances (Redactor middleware in Phase 4.5). 

## DoD

* Migrations merged and reversible.
* Factories present; schema verified in CI.

---

# T4.5-02 — PhoneTimezone service (area code → timezone)

**Epic:** E-007 • **Priority:** P0 • **Points:** 3

## Context

Quiet hours must be enforced in the **recipient’s** timezone, not the business timezone. Provide a deterministic `PhoneTimezone.lookup(e164)` for US area codes with a safe fallback.  

## Scope & Implementation

* `app/services/phone_timezone.rb`:

  * Static `AREA_CODE_TZ` map for US NANP area codes.
  * `lookup(e164)` → IANA tz string (fallback `"America/Chicago"`). 
* Unit-tested and used only by enforcement (not by analytics).

## Acceptance Criteria

* Given “+13105551234”, `lookup` returns `"America/Los_Angeles"` (example LA mapping). 

## Tests (TDD)

* Service spec for several representative area codes + default fallback.

## Gotchas

* Never use `business.timezone` for quiet hours logic (penalty risk). 

## DoD

* Service implemented; specs green; documented for reuse by QuietHours.

---

# T4.5-03 — QuietHours module (recipient timezone check)

**Epic:** E-007 • **Priority:** P0 • **Points:** 3

## Context

Enforce TCPA quiet hours (configurable window) in the **recipient’s TZ** when deciding if an outbound call is permitted. Target SLO: measurable blocks with `call_blocked_quiet_hours` events. 

## Scope & Implementation

* `app/lib/quiet_hours.rb` module:

  * `within_allowed_window?(to_e164:, settings:)`:

    * Use `PhoneTimezone.lookup` to compute local hour range. 
    * Evaluate against `compliance_settings.quiet_start_hour`..`quiet_end_hour`. 
* Expose reason codes: `"quiet_hours"`.

## Acceptance Criteria

* Calls to LA at **05:00 PT** are denied when settings allow only 08:00–21:00 local. (Demonstrated in compliance TDD.) 

## Tests (TDD)

* Unit spec: EST→PST boundary case (8am ET equals 5am PT) denies. 

## Gotchas

* TZ logic belongs in PhoneTimezone; don’t duplicate. Quiet hours must **not** use business TZ. 

## DoD

* Module shipped, used by CallPermission, covered by spec.

---

# T4.5-04 — ConsentLogger service (log with IP/statement)

**Epic:** E-007 • **Priority:** P0 • **Points:** 3

## Context

We must capture consent (who, when, what text they saw, IP/UA) before initiating calls. This is an explicit exit criterion. 

## Scope & Implementation

* `app/services/consent_logger.rb`

  * `.log!(channel:, purpose:, subject:, statement:, ip:, user_agent:, business:)` → creates `Consent`.
  * Stores `consented_at = Time.current` and raw `statement` snapshot.
* Wire into signup/trial/hosted form submits as appropriate.

## Acceptance Criteria

* Calling service with minimal required fields creates a `Consent` row with IP, UA, statement snapshot, and timestamp. 

## Tests (TDD)

* Unit spec asserts persisted fields and timestamp bounds; request spec for hosted form path in later phase. 

## Gotchas

* Must happen **before** any first outbound. (Compliance risk.) 

## DoD

* Service implemented; specs green; integrated into relevant controllers.

---

# T4.5-05 — DNC integration (API client + cache)

**Epic:** E-007 • **Priority:** P0 • **Points:** 5

## Context

Block **all** outbound calls to numbers on the internal or external DNC lists. Provide an API client + caching to avoid hot-path DB thrash. DNC appears as a core guardrail and has admin UI later.  

## Scope & Implementation

* `app/services/dnc_checker.rb`:

  * `listed?(business_id:, to_e164:)` → checks:

    1. Local table `dnc_numbers` (unique per business). 
    2. Optional external API (if configured) with short TTL cache.
* Caching in Redis with `dnc:v1:{biz}:{e164}` for 15–60m.
* Provide CSV import path later via admin (Phase 6/4.5 UI). 

## Acceptance Criteria

* Numbers present in `dnc_numbers` always return `true` from `listed?`, and outbound calls are blocked in integration tests. 

## Tests (TDD)

* Model spec: uniqueness/normalization for `DncNumber`. 
* Service spec: hits cache; integration: job path raises/denies on DNC. 

## Gotchas

* Zero tolerance: **100% block rate** to DNC numbers is a stated metric. 

## DoD

* Service implemented with Redis cache; specs cover local + external path.

---

# T4.5-06 — CallPermission service (orchestrates all checks)

**Epic:** E-007 • **Priority:** P0 (Critical) • **Points:** 5

## Context

Single gatekeeper that enforces **DNC → quiet hours → velocity caps → policy flags** and returns a structured decision with a reason code. This is the central integration the jobs will call.  

## Scope & Implementation

* `app/services/call_permission.rb`

  * `check(business:, to_e164:, context:)` → `OpenStruct(ok:, reason:, metadata:)`
  * `check!` variant raises on deny (for job short-circuit)
  * Internals call: `DncChecker`, `QuietHours`, `VelocityCaps`, and read `compliance_settings` (daily/per-min caps, trial toggle, block international). 
* Emit `AuditLog` on denials: `event="call_blocked", reason, to, context`. 

## Acceptance Criteria

* Denials return correct `reason` among: `dnc`, `quiet_hours`, `velocity_per_min`, `velocity_daily`, `trial_outbound_disabled`, `international_blocked`.
* Integration: wired later into StartTrialCall/SpeedToLead (separate ticket). 

## Tests (TDD)

* Service spec covers all denial paths + happy path. (Compliance suite calls this.) 

## Gotchas

* Idempotency of job callers is separate; service should be pure/side-effect-free except audits on denials. 

## DoD

* Service and specs merged; reason codes documented.

---

# T4.5-07 — Velocity caps (Redis counters)

**Epic:** E-007 • **Priority:** P0 • **Points:** 3

## Context

Protect against burst abuse and cost blowups using **per-minute** and **daily** caps with Redis key expirations. This is explicitly in the ticket list + non-functional targets.  

## Scope & Implementation

* In `CallPermission` add:

  * `increment_and_check!(biz_id, scope: :per_min)` using Redis `INCR` with `EXPIRE 60s`.
  * `increment_and_check!(biz_id, scope: :daily)` with `EXPIRE 86400s`.
  * Thresholds from `compliance_settings.outbound_per_min_cap`/`outbound_daily_cap`. 
* ENV: `REDIS_URL` must be configured. 

## Acceptance Criteria

* Defaults enforce **5/min and 50/day**; denials return correct reason. 

## Tests (TDD)

* Time-travel/service specs simulate counters crossing thresholds and expiring. 

## Gotchas

* Do **not** use DB for counters (race/latency). Use Redis as mandated. 

## DoD

* Methods implemented; specs green; documented Redis keys.

---

# T4.5-08 — Compliance tab UI (settings, DNC list)

**Epic:** E-007 • **Priority:** P1 • **Points:** 3

## Context

Business owners must control compliance settings and manage DNC list; surface last audits. This is specified in controllers/UI for Phase 4.5 and ticket list.  

## Scope & Implementation

* Route: `GET/POST /businesses/:id/compliance`
* View: form elements for **recording announce**, **quiet hours start/end**, **block international**, **daily/per-min caps**, **trial outbound toggle**; table for DNC entries with add/delete; recent 50 audits. 
* Persist to `compliance_settings` (1:1 per business). 

## Acceptance Criteria

* Changing settings updates values and writes an `AuditLog` entry.
* DNC add/remove reflects immediately in checks; CSV upload comes later under Admin. 

## Tests (TDD)

* System spec: owner changes quiet hours → job path denial until window opens. 

## Gotchas

* Don’t leak PII in UI/logs; ensure masking via Redactor remains on by default. 

## DoD

* Form + controller + policy checks in place; system spec passes.

---

# T4.5-09 — DataRetentionJob (unified purge)

**Epic:** E-007 • **Priority:** P1 • **Points:** 2

## Context

Purge/redact transcripts and recordings by policy: trials ≥7 days (if not converted) and paid calls per business policy. Keep consent/audit logs as legal records. This job is explicitly defined with reference code.  

## Scope & Implementation

* `app/jobs/data_retention_job.rb`:

  * `redact_trials!` → 7-day rule on non-converted trials.
  * `redact_paid_calls_with_policies!` → per-business `retain_transcripts_days`. (Reference implementation provided.)  

## Acceptance Criteria

* Running job on seeded data redacts as described; idempotent runs make no further changes. 

## Tests (TDD)

* Time-travel/job spec covers both trial and paid paths. (Retention SLOs called out in non-functional targets.) 

## Gotchas

* Do **not** delete consent/audit rows; they’re legal records. 

## DoD

* Job implemented with specs; scheduled daily; logs summary counts.

---

## Cross-Ticket Notes

* **Compliance suite**: Create `spec/compliance/tcpa_spec.rb` to exercise **quiet hours (recipient TZ), DNC block, consent logging** end-to-end. Mark as CRITICAL. 
* **Parallelization**: Phase 4.5 runs **in parallel** with Paid Product work; do **not** ship paid calls without these guardrails. 
* **Ops tripwires**: Add an alert if `call_blocked_quiet_hours == 0` for 24h to catch bypass bugs. 

Awesome—here are the detailed tickets for your next batch, formatted per the build guide style.

---

### T5-01 — Lead models (Lead, LeadSource) + migrations

**Goal / Outcome**
Persist inbound lead data and attribute where it came from so downstream calling, compliance, and analytics can function.

**User Story**
As a business, I want leads saved with source attribution so I can call them quickly and track performance.

**Scope**

* Add `leads` and `lead_sources` tables and ActiveRecord models.
* Normalization helpers for email + phone (E.164).
* Partial unique constraints to avoid dupes within a business.
* Basic enums for statuses and source kinds.

**Data Model / Migrations**

* `lead_sources`

  * `id` (PK), `business_id` (FK, index)
  * `name` (string), `kind` (enum: `hosted_form`, `api`, `csv_import`, `webhook`, `manual`)
  * `slug` (string, unique, nullable except for `hosted_form`)
  * `settings` (jsonb; form config, copy), `active` (boolean, default: true)
  * `created_at/updated_at`
  * Unique: (`business_id`, `name`)
* `leads`

  * `id` (PK), `business_id` (FK, index), `lead_source_id` (FK, index)
  * `first_name`, `last_name`, `email` (citext), `phone_e164` (string)
  * `status` (enum: `new`, `contacted`, `qualified`, `unqualified` → default `new`)
  * Consent fields: `consented_at` (timestamptz), `consent_ip` (inet), `consent_statement` (text)
  * Attribution: `utm_source`, `utm_medium`, `utm_campaign`, `utm_term`, `utm_content` (strings), `referrer` (text), `gclid` (string)
  * Operational: `notes` (text), `last_call_id` (FK nullable), `tags` (string[], default: [])
  * `created_at/updated_at`
  * Indexes:

    * Partial unique: (`business_id`, `email`) WHERE email IS NOT NULL
    * Partial unique: (`business_id`, `phone_e164`) WHERE phone_e164 IS NOT NULL
    * B-tree on (`business_id`, `created_at DESC`)
* Add `citext` extension if not present.

**Model Rules**

* Presence: `business_id`, (`email` OR `phone_e164`) at least one.
* Normalize: `email.downcase.strip`, `phone` → E.164 (or nil).
* `full_name` virtual (fallback to email/phone for display).

**Observability**
Emit events: `lead_source_created`, `lead_created`.

**Security & Compliance**
Store consent snapshot; IP stored as `inet`. PII logging guardrails—no raw phone/email in logs.

**Tests**

* Model validations, normalization.
* Partial unique constraints (phone duplicate allowed across businesses, not within).
* Enum defaults.

**Out of Scope**
UI, upsert logic, jobs, emails.

**Dependencies**
Business model.

**Estimate**: 3 pts

---

### T5-02 — `Leads::Upsert` service (phone/email deduplication)

**Goal / Outcome**
Create-or-update leads idempotently to prevent duplicates and consolidate data.

**User Story**
As a system, when the same person submits multiple times, I want one canonical Lead.

**Scope**

* Service object: `Leads::Upsert.call(business:, attributes:, source:)`
* Match priority: phone, then email (within same business).
* Merge rules: keep earliest `created_at`, prefer non-blank over blank, append tags, preserve first `consented_at` unless new call carries consent—then set to earliest or keep original (decision below).
* Audit trail: return `[:created|:updated, lead]`.

**Matching & Merge Rules**

* Find existing by `(business_id, phone_e164)` or `(business_id, email)` (normalized).
* Do not downgrade consent; set `consented_at` if currently nil and payload has consent.
* Update `lead_source_id` if blank; otherwise keep original but attach a “sources” tag (e.g., `source:hosted_form`).
* Maintain `last_call_id` untouched here.

**Observability**
Emit `lead_upserted` (properties: `action`, `matched_on`, `lead_id`, `source_kind`).

**Errors & Edge Cases**

* If both email and phone missing → validation error.
* If phone present but invalid → normalize to nil; rely on email path.
* If both phone / email map to different existing IDs (rare) → pick phone match; log warning, create `LeadMergeCandidate` event (no merge now).

**Tests**

* Create, update, no-regression on consent fields.
* Conflict on email vs phone, respects priority.
* Idempotency on identical payload.
* Service returns tuple with action.

**Out of Scope**
Cross-lead merge job, UI.

**Dependencies**
T5-01 models.

**Estimate**: 3 pts

---

### T5-03 — `SpeedToLeadJob` (immediate outbound)

**Goal / Outcome**
Call the lead as soon as they submit—driving conversion with minimal delay.

**User Story**
As a business, I want an automatic outbound call placed to new leads immediately.

**Scope**

* ActiveJob: `SpeedToLeadJob.perform_later(lead_id)`
* Preconditions: lead has `phone_e164`, business allowed to call (compliance hook), lead status `new`.
* Orchestrate:

  1. Check `CallPermission.allow?(business:, phone:)` (quiet hours, DNC, velocity caps).
  2. Initiate call via existing telephony integration (e.g., `StartAssistantCall.call(business:, lead:)`).
  3. Update `lead.last_call_id`.
  4. Update lead `status` → `contacted` on successful connect (or leave `new` if call fails to start).
* Retry policy: small exponential backoff on transient errors; drop if permanent DNC.

**Config**

* Feature flag: `speed_to_lead_enabled` per business.
* Global toggle via ENV for staging.

**Observability**

* Events: `speed_to_lead_enqueued`, `outbound_call_initiated`, `outbound_call_blocked` (reason).
* Metrics: queue latency for enqueued-to-started.

**Errors**

* Missing phone: job exits gracefully (logs info).
* Blocked by compliance: emit event, no retry.
* Telephony error: retry up to N; alert after final failure.

**Tests**

* Happy path, compliance block, missing phone, telephony failure, idempotency (re-running job doesn’t double-call).

**Dependencies**
T4.5 CallPermission (or a minimal stub now), telephony starter.

**Estimate**: 4 pts

---

### T5-04 — Seed `hosted_form` LeadSource on Business creation

**Goal / Outcome**
Every new business gets a working public lead form endpoint by default.

**User Story**
As a business onboarding, I want a ready-to-use hosted form.

**Scope**

* After `Business` creation, create `LeadSource` record:

  * `kind: 'hosted_form'`, `name: 'Hosted Form'`, `slug: shortid` (e.g., 6–8 chars, URL-safe)
  * `settings` defaults: form title, subtitle, fields enabled, consent copy (with business name placeholder), success message, theme.
* Ensure slug uniqueness across all businesses.

**Implementation**

* Callback or `BusinessProvisioner` service invoked by `ConvertTrialToBusinessJob` (or `Business.create` path).
* Guard to avoid duplicate `hosted_form` if re-run.

**Observability**
Emit `lead_source_seeded` with `slug`.

**Tests**

* Seeds exactly once, slug unique, default settings present.

**Dependencies**
T5-01 models, business creation flow.

**Estimate**: 2 pts

---

### T5-05 — `LeadFormsController` (public `/l/:slug`)

**Goal / Outcome**
Public endpoints to show and submit a mobile-optimized lead form.

**User Story**
As a prospect, I can submit my contact info via a fast, simple form.

**Routes**

* `GET /l/:slug` → new
* `POST /l/:slug` → create

**Scope**

* Controller resolves `LeadSource` by `slug` and `active: true`.
* `GET` renders form with fields per `LeadSource.settings`.
* `POST`

  * Normalize + validate.
  * Consent checkbox required; capture `request.remote_ip`, `consented_at = Time.current`, `consent_statement` snapshot from settings.
  * Pass to `Leads::Upsert`.
  * Enqueue `SpeedToLeadJob` if feature flag enabled and phone present.
  * Redirect to Thank You page (or render JSON if `Accept: application/json`).

**Anti-abuse**

* Hidden honeypot field; per-IP rate limit (Rack::Attack).
* (Optional) hCaptcha/ReCAPTCHA key-aware; no hard dependency.

**Responses**

* HTML + JSON (for headless embeds).

**Observability**

* Events: `lead_form_view`, `lead_form_submit`, `lead_form_validation_error`.

**Errors**

* Invalid/missing fields → show inline errors; never leak internal reasons.
* Unknown/disabled slug → 404.

**Tests**

* Request specs for GET/POST (HTML + JSON).
* Rate-limit behavior (mock).
* Consent capture.

**Dependencies**
T5-02, T5-03, T5-04.

**Estimate**: 4 pts

---

### T5-06 — Lead form UI (mobile-optimized, consent checkbox)

**Goal / Outcome**
Ship a clean, fast mobile form with explicit consent.

**User Story**
As a prospect on my phone, I can submit quickly and grant consent clearly.

**Scope (UI)**

* Layout: single-column, large inputs, sticky submit on mobile.
* Fields (configurable): `name`, `phone`, `email`, `message` (optional). At least one of phone/email required.
* Consent: required checkbox with linked statement; disabled Submit until checked.
* Success: thank-you state with next steps.
* Loading: disable inputs + show progress while submitting.

**Accessibility**

* Labels, aria-invalid, focus rings, error summaries.
* Keyboard-friendly; proper input modes (`tel`, `email`).

**Theming**

* Use existing design tokens; respect `LeadSource.settings.theme` (light/dark primary color).

**Validation (client)**

* Basic email/phone formats; display friendly messages.

**Analytics hooks**

* `data-analytics-id` for view/submit/error.

**Tests**

* System spec: mobile viewport, required consent, one-of email/phone, success path.

**Dependencies**
T5-05 controller.

**Estimate**: 3 pts

---

### T5-07 — Leads dashboard tab (table with call linkage)

**Goal / Outcome**
Operators can see and navigate leads, with call context.

**User Story**
As an operator, I want a sortable/filterable leads table with last call info.

**Scope (Admin App)**

* “Leads” tab under Business workspace.
* Table columns: Created (local tz), Name, Contact (email/phone), Source (name/kind), Status, Last Call (time + status badge), Tags.
* Sorting: Created desc default; allow sort by Status, Source.
* Filters: status (multiselect), source, date range, “has phone”.
* Row click → Lead detail drawer/page showing: full fields, consent snapshot, timeline of calls (link to call record).
* Empty state copy and link to hosted form URL.

**Data**

* API/Backend: index endpoint with pagination & filters (or server-rendered + Turbo).
* N+1 safe: eager load `lead_source` and `last_call`.

**Observability**

* Event: `leads_viewed`, `lead_detail_viewed`.

**Tests**

* Request spec for index filters.
* View/component specs for table rendering.
* Includes eager loading check.

**Dependencies**
T5-01, call model existing from telephony integration.

**Estimate**: 4 pts

---

### T5-08 — Lead notification email (new lead alert)

**Goal / Outcome**
Notify business stakeholders instantly when a new lead arrives.

**User Story**
As a business owner, I receive an email with lead details and a quick “Call now” action.

**Scope**

* Mailer: `LeadMailer.new_lead(lead_id)`
* Trigger from `LeadFormsController#create` after successful upsert.
* Recipients: business notification email(s) (configurable on Business), fallback to account owner; guard against empty recipient list.
* Email content:

  * Subject: `New Lead: <Name or Phone/Email>`
  * Body: name/contact, source, message (if provided), consented_at, “Open in app” CTA, deep link to call flow if applicable.
  * Do not include PII beyond necessary basics; no IP in email.
* Deliver async via ActiveJob.

**Observability**

* Event: `lead_notification_sent` (lead_id, recipients_count).

**Tests**

* Mailer rendering, jobs enqueue, no-recipient guard.
* Preview added under `/rails/mailers`.

**Dependencies**
T5-01, T5-02, T5-05.

**Estimate**: 2 pts

---

### T6-01 — `AnalyticsDaily` model + migrations

**Goal / Outcome**
Persist daily aggregates per business to power dashboards and reports.

**User Story**
As an operator, I want a fast dashboard without scanning raw events.

**Scope**

* Table: `analytics_dailies`

  * `id` (PK), `business_id` (FK, index), `date` (date)
  * `leads_count` (int), `calls_attempted` (int), `calls_connected` (int)
  * `avg_speed_to_lead_sec` (integer, nullable)
  * `new_customers` (int, nullable; future)
  * `created_at/updated_at`
  * Unique index: (`business_id`, `date`)
* Model validations and helpers (e.g., `for(business, date)` finder).
* (Note) Population job will be in a later ticket; this is schema + model only.

**Observability**

* Event: `analytics_daily_created` (when rows are inserted by later job).

**Tests**

* Model constraints, unique composite index.

**Out of Scope**
Aggregation job, dashboard UI.

**Dependencies**
Business model; underlying leads/calls exist for future rollups.

**Estimate**: 2 pts

---

## Cross-Ticket Notes (applies to this batch)

* **PII & Logs**: Never log raw email/phone; use hashed values when needed.
* **Rate Limits**: Public form hit by Rack::Attack with per-IP caps; add safelist for internal health checks.
* **Feature Flags**:

  * `speed_to_lead_enabled` per business
  * `hosted_form_captcha_enabled` per business (planned)
* **Analytics Events (naming)**: snake_case, include `business_id`, `lead_id` when applicable, client vs server origin.
* **i18n**: All user-facing strings in YAML; consent statement templated from settings with business name.

Awesome—here’s the next batch of ticket details, formatted per the build guide and consistent with the prior set.

---

### T6-02 — AnalyticsComputer service (counts/averages only)

**Goal / Outcome**
Provide a single, reliable service to compute daily counts/averages used by rollups, dashboards, and reports.

**User Story**
As the system, I need a reusable computer that returns daily metrics for a business so downstream jobs and UIs don’t duplicate query logic.

**Scope**

* Service: `AnalyticsComputer.call(business:, range: Date..Date)` → returns an immutable struct/hash with keys:

  * `leads_count`
  * `calls_attempted`
  * `calls_connected`
  * `avg_speed_to_lead_sec` (time from lead `created_at` to first attempted outbound call; only for leads with a call attempt)
* Support computing for a single day or a date range (sum/weighted avg logic inside).
* Efficient queries with proper scopes and indexes; no per-record loops.
* Null-safe averages (return `nil` if no data).

**Implementation Notes**

* Use ARel/ActiveRecord groupings by day where needed; isolate time zone via `business.timezone`.
* `avg_speed_to_lead_sec`: LEFT JOIN leads → first call attempt time; compute epoch diff and AVG.
* Strictly read-only; never mutate DB.

**Observability**

* Debug log at `:info` summarizing counts (PII-safe).

**Tests**

* Date-boundary correctness in multiple time zones.
* Speed-to-lead averaging (mixed presence/absence).
* Range aggregation vs single-day parity.

**Dependencies**
T6-01 schema; call/lead models and minimal call events.

**Estimate**: 3 pts

---

### T6-03 — AnalyticsIngestJob (after_commit hooks)

**Goal / Outcome**
Incrementally maintain `analytics_dailies` rows for “today” so dashboards are fast without waiting for nightly rollups.

**User Story**
As the system, I want to reflect new leads/calls in near real-time on the dashboard.

**Scope**

* Define `AnalyticsIngestJob.perform_later(event_type:, business_id:, occurred_at:)` which upserts into `analytics_dailies` for the local date.
* Event sources (via `after_commit`):

  * Lead created → `leads_count += 1`
  * Call attempted → `calls_attempted += 1`
  * Call connected → `calls_connected += 1`
* Idempotency: pass a stable `event_key` (e.g., `"lead:#{id}:created"`, `"call:#{id}:attempted"`) and dedupe with a Redis SET or Postgres `events_ingested` table (minimal, indexed). Pick one:

  * **Preferred**: Postgres “upsert ledger” table `analytics_event_dedup(event_key PK, occurred_at)`; ingest job wraps in transaction: insert → apply increments only on success.

**Implementation Notes**

* Upsert: `INSERT ... ON CONFLICT (business_id, date) DO UPDATE SET ...` with atomic increments.
* Local date: `occurred_at.in_time_zone(business.timezone).to_date`.

**Observability**

* Event: `analytics_ingested` (type, business_id, date, applied: true/false).

**Tests**

* after_commit hooks fire once.
* Idempotency guard works.
* Correct local date resolution near midnight boundaries.

**Dependencies**
T6-01; business time zone; Lead/Call callbacks.

**Estimate**: 3 pts

---

### T6-04 — DailyRollupJob (02:00 local finalization)

**Goal / Outcome**
Recompute and finalize yesterday’s analytics per business at a stable hour to correct drift and compute averages.

**User Story**
As an operator, I want yesterday’s numbers to be finalized by morning in my local time.

**Scope**

* Job: `DailyRollupJob.perform_for(business_id:, date:)`

  * Calls `AnalyticsComputer` for the single `date`.
  * UPSERT row in `analytics_dailies` with authoritative values (not additive increments).
* Orchestrator job scheduled hourly UTC: finds businesses whose local time is `~02:00` and enqueues `perform_for` for `(Date.yesterday in business.tz)`.
* Idempotent—safe to re-run.

**Implementation Notes**

* No schema change: “finalization” is logical (last write wins).
* Keep ingest job running all day; rollup overwrites only the past date.
* Concurrency control per business/date via Redis lock to avoid duplicate rollups.

**Observability**

* Event: `analytics_rollup_finalized` (business_id, date).
* Metric: rollup duration per business.

**Tests**

* Correct time zone date selection.
* Overwrite vs append semantics.
* Concurrency (only one wins).

**Dependencies**
T6-02, T6-03.

**Estimate**: 3 pts

---

### T6-05 — Analytics dashboard (7-day tiles, no charts)

**Goal / Outcome**
Simple, fast, legible dashboard showing the last 7 days of core metrics.

**User Story**
As a business user, I want to quickly scan my last week performance.

**Scope (UI/UX)**

* Location: Business workspace → “Analytics” tab.
* Tiles for each metric with 7-day summary and per-day mini list (no charts):

  * Leads (sum)
  * Calls Attempted (sum)
  * Calls Connected (sum, plus connection rate %)
  * Avg. Speed to Lead (mean seconds; show hh:mm:ss)
* “Yesterday vs prior 7-day average” small delta on each tile.
* Range picker preset: Last 7 days (read-only in MVP).
* Empty states and loading skeletons.

**Backend**

* Fetch via `AnalyticsDaily.where(business_id, date: last_7)`; compute deltas in presenter.
* Ensure N+1-safe.
* P95 render time budget: < 200ms server-side (excluding network).

**Accessibility**

* High-contrast tiles; aria labels; readable number formatting.

**Observability**

* Events: `analytics_viewed` (business_id), `analytics_tile_expanded` (metric).

**Tests**

* Request spec verifies correct date window and aggregates.
* View/component specs for tiles, deltas, empty state.

**Dependencies**
T6-01..T6-04.

**Estimate**: 4 pts

---

### T6-06 — DailyReportJob + email template

**Goal / Outcome**
Send a concise daily email summary for yesterday’s performance.

**User Story**
As a business owner, I want a morning snapshot of key metrics.

**Scope**

* Job: `DailyReportJob.perform_for(business_id:, date:)`

  * Pull finalized `analytics_dailies` for `date`.
  * Compose email via `AnalyticsMailer.daily_report(business_id, date)`.
* Scheduler: enqueue per business at `07:30` local time (feature flag `daily_report_enabled`).
* Email contents:

  * Subject: `Your Daily Summary — <Mon, Oct 24>`
  * Body: leads, calls attempted/connected (and %), avg speed-to-lead; link to dashboard.
  * “Manage notifications” link (settings page).
  * No PII; business branding optional from settings.

**Observability**

* Event: `daily_report_sent` (business_id, date).
* Metric: delivery success count.

**Tests**

* Mailer previews; i18n strings; job scheduling mocks.
* Missing row edge case → graceful “no data” message.

**Dependencies**
T6-04 finalized rows.

**Estimate**: 2 pts

---

### T6-07 — System analytics (admin MRR/conversion)

**Goal / Outcome**
Provide an internal admin view of global business health: MRR and key conversion funnels.

**User Story**
As an admin, I need a snapshot of revenue and conversion to steer operations.

**Scope**

* Admin-only page: `/admin/analytics` with tiles (no charts in MVP):

  * **MRR** (current) and **MRR Δ 30d** (requires Stripe client from T3 series).
  * **Trial → Paid conversion %** (last 30 days cohort).
  * **Lead → Call Attempted %** (last 7 days).
  * **Call Attempted → Connected %** (last 7 days).
  * **Avg speed-to-lead (global)** last 7 days.
  * **Active businesses (7d)** count.
* Data adapters:

  * Stripe: current subscriptions, plan amounts → MRR (USD).
  * DB: counts based on existing tables (`trials`, `businesses`, `leads`, `calls`).

**Security**

* Admin RBAC only; server-rendered to avoid exposing sensitive aggregates to clients.

**Observability**

* Event: `admin_analytics_viewed`.
* Cache results for 5 minutes in memory/Redis.

**Tests**

* Service specs for each tile’s calculation.
* Authorization test (forbidden to non-admins).

**Dependencies**
Stripe client (T3-01), checkout/webhooks (T3-02/03), analytics computed fields (T6-*).

**Estimate**: 4 pts

---

### T6-08 — Performance optimization (<500ms @ 50 calls)

**Goal / Outcome**
Ensure analytics endpoints and dashboard render within 500ms p95 under 50 concurrent requests.

**User Story**
As a user, I want snappy analytics even during traffic bursts.

**Scope**

* Add/verify DB indexes:

  * `analytics_dailies (business_id, date)` (unique already), plus covering index for frequent range queries `(business_id, date DESC)`.
  * Calls/leads date indexes used by `AnalyticsComputer`.
* Query tuning:

  * Replace per-day loops with single GROUP BY queries in `AnalyticsComputer`.
  * `includes(:lead_source, :last_call)` on tables that render in the UI.
* Caching:

  * Low-level cache for dashboard 7-day payload keyed by `business_id` with 60s TTL.
  * Bust on `AnalyticsIngestJob` writes for “today”.
* N+1 detection: Bullet in dev/test; CI fails on new N+1.
* Instrumentation: `rack-mini-profiler` dev; custom ActiveSupport notifications around `AnalyticsComputer`.
* Load test script (k6) checked into `scripts/perf/k6_analytics.js` with a README (optional to run locally).

**Acceptance (perf)**

* p95 server time (Rails log instrumentation) ≤ 500ms @ 50 concurrent hits on analytics index in staging data set (≥ 1M rows synthetic OK).
* DB query count for dashboard request ≤ 6.

**Tests**

* RSpec-benchmark for `AnalyticsComputer` call (upper bound).
* Automated Bullet check in CI.
* Unit tests for caching/busting.

**Dependencies**
T6-02..T6-05.

**Estimate**: 5 pts

---

### OPS-01 — Configure Sentry Alert Rules (11 tripwires)

**Goal / Outcome**
Proactive detection of regressions, failures, and burning money.

**Scope**
Create Sentry alerts (Environment: `production` unless noted), owners, and thresholds:

1. **Error Rate Spike**: Project error rate > 5% for 5 min (pager).
2. **New Issue Volume**: > 20 new issues in 10 min (slack #alerts).
3. **Endpoint p95 Slow**: `/businesses/:id/analytics` p95 > 800ms for 10 min (slack).
4. **Job Retry Storm**: `SpeedToLeadJob` error rate > 5 in 10 min (pager).
5. **Dead Letter**: Sidekiq Dead set > 10 jobs (pager).
6. **Queue Latency**: `default` queue latency > 60s for 5 min (slack).
7. **Webhook Signature Failures**: Stripe or Telephony webhook errors > 10 in 10 min (pager).
8. **Outbound Call Fail %**: call start failures > 10% in 15 min (pager).
9. **DB Timeout**: `ActiveRecord::QueryCanceled` occurrences > 5 in 5 min (pager).
10. **Memory Bloat**: Process RSS > 1.2x baseline for 10 min (slack; use Sentry Perf or infra metric integration).
11. **Release Regression**: New release introduces 2x error rate within 30 min of deploy (pager).

**Runbooks**
Link RB-01…RB-05 to appropriate alerts.

**Tests/Verification**

* Send test events; confirm channel delivery and ownership.

**Dependencies**
Sentry DSN configured; Sidekiq integrated.

**Estimate**: 2 pts

---

### OPS-02 — Document Runbooks RB-01 through RB-05

**Goal / Outcome**
Clear, repeatable response for top-5 incidents.

**Artifacts**
Create `/docs/runbooks/` with five Markdown files:

* **RB-01 Outbound Calls Failing**

  * **Triggers**: OPS-01 #8, call initiation errors spike.
  * **Immediate actions**: Toggle feature flag `speed_to_lead_enabled` to OFF for affected businesses; post status in #ops.
  * **Diagnosis**: Check telephony provider status, error codes, recent deploys; sample call logs.
  * **Remediation**: Retry safe calls, throttle attempts, open provider ticket.
  * **Verification**: Monitor error/connection rate returning to baseline.
  * **Postmortem**: Fill template `/docs/runbooks/POSTMORTEM.md`.

* **RB-02 Stripe Webhook Failures**

  * **Triggers**: OPS-01 #7.
  * **Immediate**: Pause new checkouts if necessary; replay recent events from Stripe dashboard.
  * **Diagnosis**: Signature validation, endpoint health, recent code changes.
  * **Remediation**: Patch & deploy; reprocess DLQ.
  * **Verification**: All pending invoices synced; dunning re-enabled.

* **RB-03 Queue Latency / Backlog**

  * **Triggers**: OPS-01 #6.
  * **Immediate**: Temporarily scale workers; pause non-critical jobs.
  * **Diagnosis**: Hot job IDs, long-running queries, lock contention.
  * **Remediation**: Add concurrency limits, break large batches, index.
  * **Verification**: Latency < 30s sustained.

* **RB-04 DB Errors After Deploy**

  * **Triggers**: OPS-01 #9, sudden 5xx.
  * **Immediate**: Roll back release; set maintenance if needed.
  * **Diagnosis**: Migrations, long transactions, query plans.
  * **Remediation**: Hotfix; add indexes; retry safe requests.
  * **Verification**: Error rate back to baseline; migration audited.

* **RB-05 Lead Form Abuse / Spam Spike**

  * **Triggers**: Sudden lead surge with low connect, WAF alerts.
  * **Immediate**: Enable captcha flag; raise Rack::Attack thresholds; block ASNs.
  * **Diagnosis**: IPs, user agents, referrers.
  * **Remediation**: Harden honeypots; rate-limit per IP/subnet; add content checks.
  * **Verification**: Abuse metrics drop; legit conversion stable.

**Acceptance**
Each runbook includes: trigger, owner, severity, SLAs, step-by-step actions, rollback, comms template, verification checklist, and postmortem link.

**Estimate**: 3 pts

---

### OPS-03 — Test Runbooks on Staging

**Goal / Outcome**
Prove runbooks are actionable by simulating incidents.

**Scope**

* Create a “Game Day” checklist in `/docs/runbooks/GAMEDAY.md`.
* Simulations (staging):

  1. Telephony start-call failure injection (mock provider returns 5xx) → follow RB-01.
  2. Stripe webhook 401 via bad secret → RB-02; verify replay.
  3. Induce queue latency by pausing workers for 5 min → RB-03; recover.
  4. Force slow query (disable index in staging copy) → RB-04; observe alerts.
  5. Spam burst: scripted POSTs to `/l/:slug` → RB-05; rate-limit and captcha toggle.
* Record timings, gaps, and update runbooks accordingly.

**Acceptance**

* Each simulation ends with a PR improving the relevant runbook.
* Sentry alerts and Slack/Pager routes observed as expected.

**Dependencies**
OPS-01 alerts active; OPS-02 runbooks merged.

**Estimate**: 2 pts

---

## Cross-Ticket Notes (applies to this batch)

* **Time Zones**: Always compute dates in `business.timezone`. Fallback to `America/Chicago` if unset.
* **Idempotency**: All jobs accept idempotency keys or lock scopes to tolerate retries.
* **PII Guardrails**: No phone/email/IP in logs or emails beyond minimal business need.
* **Caching**: Prefer short TTL caches and explicit busting on ingest for “today”.
* **Feature Flags**: `daily_report_enabled`, `speed_to_lead_enabled`, `captcha_enabled`.
* **i18n**: Email and dashboard strings in YAML; date formatting respects locale.

