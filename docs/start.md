# Beaker AI — Project Intro

**Doc Owner:** Founder
**Audience:** Engineers, Designers, PM, Ops
**Last Updated:** Oct 25, 2025 (Strategic layering added: 3-stage summary, priority markers [MVP/POST-LAUNCH/PHASE 7+], tripwire alerts, standardized exit criteria, simplified analytics scope)

---

## Executive Summary (Read This First)

**Critical Success Factor:** The trial IS the product. Users must feel personalized value in <60 seconds.

**Three Non-Negotiables:**
1. **Phase 4.5 Compliance runs IN PARALLEL with Phase 4** - TCPA liability begins with first paid outbound call
2. **Admin panel ships FIRST in Phase 4 (P4-01)** - Required for debugging conversion failures and webhook issues without SSH
3. **Concurrency fixes (with_lock + unique constraints) are mandatory** - Race conditions create duplicate charges and lost leads
4. **Test critical paths before shipping each phase** - Webhook idempotency, TCPA compliance, race conditions (see Section 12)
5. **Incident Response Runbooks (RB-01 through RB-05)** - Pre-defined procedures for top 5 failure scenarios (see Section 8.6)

**⚠️ PRICING MARGIN PROTECTION:**
The Pro plan pricing has been adjusted to 300 included calls (from an initial 500) to ensure sustainable 50%+ margins against Vapi/OpenAI costs ($0.60-0.85/call). This protects against vendor price increases and platform overhead. The original 500-call tier would have resulted in 15-40% margins—too thin for long-term viability.

**Key Metrics:**
- TTFC (Time to First Call): ≤10s P95
- TTFA (Time to First Agent): ≤20s P95  
- Trial → Paid Conversion: Target >15% (North Star until 100 paying customers)
- Week 1 Success Rate: >40% (paid users completing: number assigned + form shared + dashboard viewed 2+)
- Error Budget: <1% failed trial calls/day
- Trial Call Success Rate: >85% (connected/requested)

**North Star Metric Progression:**
- **Months 0-3:** Trial→Paid Conversion (>15%) — Primary focus until 100 paying customers
- **Months 3-6:** Week 1 Success Rate (>40%) — Activation becomes key metric
- **Months 6+:** Weekly Active Businesses (WAB) — Retention and engagement focus

**Cost Controls:**
- Trial abuse prevention (email normalization + IP throttles) prevents $600+/month burn
- Caps: ≤3 calls/trial, ≤120s/call

**GTM Foundation:**
- Primary ICP: HVAC emergency services (Section 1.5)
- Positioning: "Call hot leads in 60 seconds, not 60 minutes" (Section 2.5)
- Pricing: $199/mo Starter (100 calls), $499/mo Pro (500 calls) — usage-based (Section 3.5)
- Pre-launch validation: $200 budget, 100 emails, validate before Phase 1 (Section 10.6)

---

## Build Strategy: 3 Stages to Launch

This plan groups the detailed technical phases (0-6) into three strategic stages for execution clarity. Each stage has a clear goal, measurable exit criteria, and demoable outcomes. Use this for planning and resource allocation; refer to the detailed phase breakdowns (Sections 9+) for implementation specifics.

### Stage 1: Validate & Ship Trial (Phases 0-2) — 4-6 weeks

**Goal:** Prove <60s time-to-value with HVAC ICP and validate market demand before heavy investment.

**What Ships:**
- Pre-launch validation (Section 10.6): 100 emails, manual demos
- Rails foundations (Phase 0): Auth, jobs, webhooks, circuit breakers
- Trial flow (Phase 1): Magic-link signup, personalized assistant, outbound call (≤3 calls, ≤120s)
- Mini-report (Phase 2): Real-time webhook processing, recording/transcript display
- Abuse prevention: Email normalization, IP throttles, cost monitoring

**Exit Criteria:**
- **Validation:** 5+ positive responses from HVAC outreach, 1+ manual demo completed
- **Product:** Prospect can sign up, build agent, receive call, see mini-report in <60s
- **Metrics:** TTFC ≤10s P95, TTFA ≤20s P95, trial call success rate >85%
- **Cost:** Trial abuse auto-blocks working, cost/trial P90 <$0.70
- **Operations:** Circuit breakers functional, webhook idempotency tested

**Risks Mitigated:** ICP mismatch (pre-launch validation), trial abuse (layered controls), vendor outages (circuit breakers)

---

### Stage 2: Monetize & Comply (Phases 3-4.5) — 4-6 weeks

**Goal:** First 10 paying customers with zero TCPA violations and operational debuggability.

**What Ships:**
- Stripe conversion (Phase 3): Checkout, business creation, paid assistant
- **Admin panel FIRST (P4-01):** Webhook inspection, event reprocessing, entity search
- Compliance (Phase 4.5, IN PARALLEL): Recipient-timezone quiet hours, DNC, consent logging, velocity caps
- Paid product (Phase 4): Twilio number assignment, live dashboard, inbound call handling

**Exit Criteria:**
- **Revenue:** 10 paying customers, trial→paid conversion >15%
- **Compliance:** 100% consent coverage, quiet hours enforced (recipient timezone), zero violations
- **Operations:** Admin panel operational, webhook reprocessing tested, no SSH required for debugging
- **Metrics:** Week 1 success >40% (number + form + dashboard views)
- **Security:** Race conditions prevented (unique constraints), idempotency verified

**Risks Mitigated:** TCPA liability (parallel compliance), conversion failures (admin tools), duplicate charges (database constraints)

---

### Stage 3: Scale & Automate (Phases 5-6) — 4-6 weeks

**Goal:** Speed-to-lead value delivery + operational autonomy (<2 hrs/week).

**What Ships:**
- Speed-to-lead (Phase 5): Hosted lead forms, immediate outbound calls, lead-to-call linking
- Analytics (Phase 6): Daily snapshots, dashboard tiles, trend tracking
- Reporting: Automated daily email reports per business
- Operations: Full runbooks (RB-01 to RB-05), auto-jobs (retention, abuse, rollups), SLO alerts

**Exit Criteria:**
- **Product:** Lead form → call → dashboard display working E2E
- **Activation:** >40% Week 1 success rate maintained
- **Operations:** <2 hours/week founder time on ops, auto-blocks/retries/reports running
- **Observability:** Tripwire alerts configured (Section 8.7), dashboards live
- **Readiness:** Runbooks tested, backup/restore drilled, expansion plan documented

**Risks Mitigated:** Operational overload (automation), retention (analytics/reports), scalability (performance budgets)

---

**Note:** The stages above provide strategic context. Implementation details, code patterns, and acceptance criteria are in the phase-by-phase breakdowns starting at Section 9 (Roadmap). Use stages for planning; use phases for building.

---

## 1) What is Beaker AI?

Beaker AI is a voice-first agent that answers and places business phone calls. In minutes, a prospect can experience a tailored agent for their business, and—once paid—go live with a dedicated number, lead capture, and a real-time dashboard.

**Vision:** deliver a minimum *lovable* solution (MLS) that converts trials to paid by letting users *feel* the product value in one minute.

**Primary users**

* **Owner/Operator** (e.g., gym, dental, HVAC): wants fast setup, real leads, fewer missed calls.
* **Buyer on trial:** wants to preview *their* agent and hear it in action before paying.

**Core outcomes**

* Speed-to-lead: call interested prospects immediately.
* First-contact resolution: answer FAQs, capture contact, (simulate) scheduling.
* Observability: recordings, transcripts, and lead data in one place.

---

## 1.5) Primary ICP & Market Focus (MVP Launch Strategy)

**Strategy:** Build for multiple verticals (gym, dental, HVAC) but validate with ONE tight ICP first.

### Primary Launch ICP: HVAC Emergency Services (Weeks 1-4)

**Why HVAC first:**
- Highest pain: Lost after-hours call = $500-2,000 lost job
- Clear ROI: Calculate revenue per missed call
- Fast decision cycle: Emergency context creates urgency
- Trial proves value instantly: Outbound call in <60s demonstrates capability

**Profile:**
* **Firmographics:** 1-5 employees, $50K-150K annual revenue, US-based
* **Current solution:** Personal cell phone + voicemail, or expensive answering service
* **Pain quantification:** 5-15 after-hours calls/week, 40% missed = $4K-8K/month lost revenue
* **Buying triggers:** Peak season (summer), bad review from missed call, hiring freeze
* **Search behavior:** "emergency plumbing answering service", "hvac after hours calls"
* **Decision criteria:** (1) Works immediately, (2) Affordable, (3) Sounds professional

### Secondary ICPs (Expand After 10 Customers)

**Gym/Fitness Studios:**
* Pain: Trial-to-membership conversion, front desk during classes
* JTBD: Convert website visitors to booked intro sessions
* Trigger: Low conversion rate, staff turnover

**Dental Practices:**
* Pain: Emergency triage, appointment scheduling, no-shows
* JTBD: Fill last-minute cancellations, handle after-hours emergencies
* Trigger: Expansion to new location, front desk inefficiency

**Market Entry Sequence:**
1. Validate with HVAC (Weeks 1-8)
2. Expand to Gym (Months 3-4, reuse lead_intake scenario)
3. Add Dental (Months 5-6, add scheduling scenario)

This strategy allows scenario_templates (Section 6) to support all three while focusing marketing dollars on the highest-ROI ICP first.

---

## ⚠️ CRITICAL IMPLEMENTATION NOTES (READ FIRST)

**Before implementing this plan, engineers MUST incorporate these critical fixes identified in technical review:**

### 1. **Phase Timing** 
Phase 4.5 (Compliance) runs IN PARALLEL with Phase 4, not after. TCPA liability begins immediately with paid outbound calling.

### 2. **Race Condition Prevention (Database-First)**
Use atomic upserts over `with_lock` for better performance:
```ruby
# ✅ GOOD: Atomic upsert (database constraint wins)
Lead.create_with(name: name, email: email)
    .find_or_create_by!(business_id: business.id, phone: phone)

# ⚠️ OK: Pessimistic lock (use only for complex state transitions)
trial_session.with_lock do
  trial_session.increment!(:calls_used)
end

# ❌ BAD: Race condition
lead = Lead.find_or_initialize_by(business_id: bid, phone: phone)
lead.update!(name: name) # Another process might have created it
```

All webhook processing and job handlers use database unique constraints as the ultimate arbiter. See `ProcessVapiEventJob` for the `begin/rescue ActiveRecord::RecordNotUnique` pattern.

### 3. **Resilience (Circuit Breakers + Timeouts)**
HTTP timeouts and circuit breakers are CRITICAL additions to Phase 0 (T0.14). Without these, external service outages cause cascading platform failures.
```ruby
# All external clients MUST have:
# - Timeouts: connect_timeout: 5s, operation_timeout: 10-20s
# - Circuit breakers: threshold: 5 failures, timeout: 60s
# - Graceful degradation: raise domain-specific errors
```

### 4. **TCPA Compliance (Recipient Timezone)**
Quiet hours MUST use **recipient's timezone** (derived from phone area code), not business timezone.
```ruby
# ❌ WRONG: $500-$1,500 per call violation
QuietHours.check(business.timezone)

# ✅ RIGHT: Derive from recipient phone
recipient_tz = PhoneTimezone.lookup(lead.phone)
QuietHours.check(recipient_tz)
```
Phase 1 uses naive implementation (trials only). Phase 5 MUST upgrade before launching paid outbound.

### 5. **Admin Panel Priority**
Admin panel is P4-01 (first ticket in Phase 4). Required for debugging conversion failures and webhook issues without SSH access.

### 6. **Performance Monitoring**
- Bullet gem for N+1 detection in dev/test
- Partial indexes for filtered queries (active businesses, recent calls)
- Connection pool configured to prevent exhaustion

See inline ⚠️ warnings throughout each phase for specific implementation details.

---

## 2) Product at a Glance

### Trial (auth required via magic link)

1. Prospect enters email → magic link sign-in (captures UTM + marketing consent).
2. Builds a personalized, capped assistant (≤120s/call, ≤3 calls).
3. Prospect clicks **Call me now** → receives an outbound call from their agent.
4. Trial page shows mini-report after calls (recording, transcript snippet, captured fields).

### Paid (after Stripe Checkout)

1. Convert trial → create paid assistant (no time caps).
2. Assign a Twilio number and connect to the paid assistant.
3. Dashboard shows live calls, transcripts, lead capture, and starter analytics.
4. Hosted lead form `/l/:slug` triggers **Speed-to-Lead** outbound calls.

**Compliance guardrails** (Phase 4.5): consent logging, quiet hours, DNC, velocity caps, basic retention.

---

## 2.5) Positioning & Messaging

### Core Positioning

**Primary Value Prop:** Call hot leads in 60 seconds, not 60 minutes—before they call your competitor.

**One-Liner:** "Speed-to-lead voice AI that turns missed calls into booked jobs."

**Tagline:** Never lose a lead to response time again.

**Alt-X-for-Y:** "Calendly for phone calls" or "Smith.ai for small businesses"

### Messaging by Use Case

**After-Hours Coverage (HVAC Primary):**
* Headline: "Your phone answered at 2 AM while you sleep"
* Pain: "40% of service calls happen outside business hours. Your competitors are answering them."
* Proof: "Captured 87 emergency calls last month that would've gone to voicemail."

**Speed-to-Lead (All Verticals):**
* Headline: "Call hot leads in 60 seconds, not 60 minutes"
* Pain: "Every minute you wait, conversion drops 10%. Most businesses wait 47 minutes."
* Proof: "Average response time: 8 seconds. Industry average: 47 minutes."

**Zero Missed Calls (Gym/Dental):**
* Headline: "Never miss a call again. Ever."
* Pain: "Each missed call is a $200-2,000 opportunity walking to your competitor."
* Proof: "99.2% answer rate across 4,283 calls last month."

### Top Objections & Responses

**1. "Will this sound robotic and annoy customers?"**
* Response: "Call yourself right now—you can't tell. Uses ElevenLabs voice (same tech as major podcasts) with your business context."
* Proof: Trial demo in <60 seconds

**2. "Is this legal? TCPA compliance?"**
* Response: "Built-in quiet hours, consent logging, DNC checks. More compliant than most human teams."
* Proof: Show compliance dashboard (Phase 4.5)

**3. "Too expensive / complicated to set up?"**
* Response: "One captured job pays for 3+ months. Setup in 10 minutes—no coding, no IT team."
* Proof: TTFA <20s, video walkthrough

**4. "What if it gives wrong information?"**
* Response: "It only shares facts you provide (hours, pricing, services). Can't make up information. Escalates complex questions to you."
* Proof: Show knowledge base editor + escalation logs

**5. "Will this replace my staff?"**
* Response: "No—it handles overflow and after-hours so your team focuses on in-person service. Think of it as your 24/7 backup."
* Proof: Customer testimonial showing team appreciation

### Proof Points (Build These First)

* Time-to-first-call: <10s (SLO from Section 11)
* Trial completion rate: >85% (quality signal)
* Sample recording: 2-minute call showing lead capture
* Cost calculator: "X missed calls/week = $Y lost revenue"
* Compliance badge: "TCPA Compliant" (Phase 4.5 complete)

**Copy Testing Priority (First 30 Days):**
1. Speed-to-lead angle (primary)
2. After-hours coverage (HVAC-specific)
3. Zero missed calls (broader appeal)

Use Section 13.7 experiments to validate which resonates best per ICP.

---

## 3) Why we win

* **Feel before buy:** trial focuses on *their* agent calling *them*—not setup.
* **Minutes to value:** magic link → call in ~30–60s → clear next step to upgrade.
* **Operationally simple:** Vapi handles the media/LLM; we orchestrate and log.

---

## 3.5) Pricing & Packaging

### Tier Structure (Usage-Based)

**Free Trial**
* Duration: 7 days OR 3 calls (whichever first)
* Limits: 120 seconds per call (enforced in Vapi assistant config)
* Requirements: Email + consent (no credit card)
* Conversion triggers: Modal after call #3, email after 48hrs, dashboard CTA

**Starter — $199/month**
* 100 calls included
* Overage: $1.50/call
* 1 phone number
* 1 scenario template (lead_intake, scheduling, or info)
* Basic dashboard (calls, leads, recordings)
* Email support (24hr response)
* Target: Solo operators, single-location businesses

**Pro — $499/month**
* 300 calls included
* Overage: $1.25/call
* 3 phone numbers
* All scenario templates + custom prompts
* Advanced analytics (Phase 6 dashboards)
* Lead form hosting (Phase 5)
* Priority support (4hr response)
* Target: Multi-location, agencies, higher volume

**Enterprise — Custom** **[POST-LAUNCH]**
* Unlimited calls
* Custom integrations (CRM, calendar)
* Multi-user/team access
* API access
* White-label options
* Dedicated success manager
* Target: Franchises, agencies with 10+ clients (defer until 100 customers)

### Add-Ons **[PHASE 7+]**
* Extra phone number: $20/month
* Custom voice (voice cloning): $49/month one-time + $10/month
* Compliance pack (DPA, consent archive, audit export): $99/month
* Calendar integration (Cal.com, Google): $15/month

### Money-Back Guarantee
* 14 days, no questions asked
* Automatically offered if <5 calls in first week (signals low engagement)
* Full refund via Stripe within 5 business days

### Pricing Rationale

**Cost Structure (per 5-minute call):**
* Vapi (GPT-4 + ElevenLabs): ~$0.50-0.75
* Twilio inbound: ~$0.04
* Twilio outbound: ~$0.07
* **Total cost: ~$0.60-0.85 per call**

**Margins:**
* Starter: $199 / 100 calls = $1.99/call → $1.10-1.40 margin (~60-70%)
* Pro: $499 / 300 calls = $1.66/call → $0.81-1.06 margin (~49-64%)
* Overage: $1.50/$1.25 → healthy margins for scale

⚠️ **CRITICAL MARGIN PROTECTION:** Pro plan adjusted to 300 calls to ensure sustainable ~50% margins. At 500 calls ($1.00/call), margins were only 15-40% against $0.60-0.85 COGS, leaving no buffer for Vapi/OpenAI price increases or platform overhead.

**Why Usage-Based Works:**
1. Low barrier to entry ($0 trial)
2. Self-qualification (heavy users pay more)
3. Fair: small businesses pay less, high-volume pays more
4. Protects margin at scale
5. Aligns cost with value delivered

### Implementation (Phase 3)

**Stripe Products/Prices:**
```ruby
# config/initializers/stripe.rb
PLANS = {
  starter: { 
    price_id: ENV['STRIPE_PRICE_STARTER'], 
    base: 199_00, 
    calls: 100, 
    overage: 150  # $1.50/call
  },
  pro: { 
    price_id: ENV['STRIPE_PRICE_PRO'], 
    base: 499_00, 
    calls: 300,   # Adjusted from 500 for sustainable margins
    overage: 125  # $1.25/call
  }
}

# Note: Metered usage requires storing subscription_item_id (see Phase 3 implementation)
```

**Usage Metering:** **[POST-LAUNCH - Deferred to Phase 6]**
* Phase 3 MVP: Fixed subscription pricing only ($199 or $499/mo)
* Phase 6: Add metered usage when customers approach caps
* Implementation: Report call usage to Stripe via webhook (ProcessVapiEventJob)
* Monthly invoice includes base + overage
* Grace period: 7 days for payment failures (dunning in Section 7)

**Trial Enforcement:**
* Database: `trial_sessions.call_limit = 3, seconds_cap = 120`
* Vapi: `callTimeLimitSeconds: 120` in assistant config
* Job: `StartTrialCallJob` checks `calls_used < call_limit` with atomic increment

**Critical Stripe Setup Requirements:**

1. **Enable Stripe Tax** (non-negotiable for US sales tax & EU VAT compliance):
   - Enable in Stripe Dashboard under Settings → Tax
   - Add `automatic_tax: { enabled: true }` to all Checkout Session calls
   - Stripe handles collection, reporting, and remittance automatically

2. **Store Metered Subscription Item ID** **[POST-LAUNCH - Phase 6]** (required for usage reporting):
   ```ruby
   # In ConvertTrialToBusinessJob, after subscription creation:
   subscription = Stripe::Subscription.retrieve(stripe_subscription_id, {
     expand: ['items']
   })
   # Find the metered usage item (configured in Stripe Dashboard)
   metered_item = subscription.items.data.find { |i| 
     i.price.recurring&.usage_type == 'metered' 
   }
   business.update!(stripe_metered_item_id: metered_item.id)
   ```

3. **Report Usage via Webhook** **[POST-LAUNCH - Phase 6]** (implemented in ProcessVapiEventJob):
   - Only report for paid calls (not trial)
   - Use `Stripe::SubscriptionItem.create_usage_record`
   - Stripe auto-calculates overage at invoice time

### Upgrade Flow (Phase 3)

1. User clicks "Upgrade" in trial page → `/stripe/checkout`
2. Stripe Checkout Session (pre-filled email, plan selection)
3. `checkout.session.completed` webhook → `ConvertTrialToBusinessJob`
4. Business created, paid assistant created (no caps), welcome email sent
5. Redirect to `/businesses/:id/onboarding` → "Assign Number" CTA (Phase 4)

### Pricing Experiments (Phase 6, Section 13.7)

* Test $149 vs $199 Starter (conversion vs margin tradeoff)
* Test 3-tier vs 2-tier display (anchor effect)
* Test annual prepay discount (12 months for price of 10)

---

## 4) High-Level Architecture (Rails)

```
[Web (Rails/Turbo/Tailwind)]
   |  magic link auth
   v
[Trial Builder] --(Jobs)--> [OpenAI KB]
   |                         [Vapi Assistant (trial)]
   |                                 ^
   |  call me now                    | serverUrl webhooks
   v                                 |
[Vapi Outbound] ----> [Call happens] | ----> [Webhooks Controller]
                                       --> [Jobs] --> [trial_calls/calls]
                                       --> [ActionCable] --> [UI live updates]

Paid path:
[Stripe Checkout] -> [Convert Trial] -> [Business + Paid Assistant]
[Assign Twilio Number] -> Twilio voice URL -> Vapi phone bridge
[Hosted Lead Form] -> Speed-to-Lead job -> Vapi Outbound -> Webhooks -> Dashboard
```

**Stack**

* **Backend:** Ruby on Rails 7.1, Postgres (UUID), Redis, Sidekiq, ActionCable.
* **Auth:** Devise + passwordless magic links.
* **Frontend:** 
  - Turbo, Stimulus, Tailwind CSS
  - ViewComponents (component library architecture)
  - Design System: CSS variables + semantic tokens
  - Mobile-first responsive (375px → desktop)
* **Voice AI:** Vapi.ai (OpenAI model + ElevenLabs voice).
* **Telephony:** Twilio (owned numbers; Twilio points to Vapi phone endpoint).
* **Payments:** Stripe Checkout + webhooks.
* **Email:** Transactional (Resend/SendGrid).
* **Observability:** Sentry; structured logs (PII redacted).

**UI/UX Architecture**
- Component-driven: ViewComponents for all UI primitives
- Design tokens: CSS variables for colors, spacing, typography
- Progressive enhancement: Hotwire for real-time updates
- Accessibility baseline: Keyboard nav, WCAG 2.1 AA contrast
- Performance budget: <100KB JS, LCP <2s, CLS <0.02

---

## 5) Key Flows (happy path)

### A) Trial call

* Create `TrialSession` (owned by User) → `CreateTrialAssistantJob` builds Vapi assistant → user clicks **Call me now** → `StartTrialCallJob` triggers outbound → Vapi webhooks post `call.ended` → `ProcessVapiEventJob` persists mini-report → Turbo updates trial page.

### B) Upgrade → Paid

* Stripe checkout → webhook `checkout.session.completed` → `ConvertTrialToBusinessJob` creates `Business` + paid assistant → email: "Agent ready" → user lands in onboarding shell.

### C) Assign number & go live

* Dashboard → **Assign Number** → `AssignTwilioNumberJob` buys number, sets Twilio voice URL to Vapi assistant → inbound calls logged via Vapi webhooks → dashboard updates in real time.

### D) Hosted lead form → Speed-to-Lead

* Public form `/l/:slug` → upsert `Lead` → `SpeedToLeadJob` calls the lead immediately → paid webhook logs call and links to lead → owner email: new lead.

---

## 6) Data Model (high level)

* **users** ←(1:N)→ **trial_sessions** (ephemeral demos)
* **trial_calls** (from webhooks, tied to trial_session)
* **businesses** (converted customers)
* **calls** (paid call logs, tied to business, optional `lead_id`)
* **leads**, **lead_sources** (hosted form, future integrations)
* **email_subscriptions**, **consents**, **dnc_numbers**
* **webhook_events** (idempotency for Vapi/Stripe)
* **analytics_daily** (snapshots for tiles & charts)

---

## 6.5) Design System & UI Foundation

### Tokens (CSS Variables)
- Colors: Semantic (--bg, --fg, --brand, --success, --warn, --danger)
- Spacing: 2, 4, 8, 12, 16, 20, 24, 32, 40
- Typography: System font stack, scale from 12px (xs) to 30px (3xl)
- Radius: sm(4px), md(8px), lg(12px), xl(16px)
- Elevation: Subtle shadows for cards, medium for popovers, high for modals

### Component Library (ViewComponents)
**Primitives:** Button, Input, Checkbox, Select, Badge, Card, Dialog, Toast
**Voice/Call:** CallCard, AudioPlayer, Transcript, ConsentNotice
**Data:** StatTile, Table, DataList
**Layout:** AppShell, PageHeader, PageSection

### Mobile-First Responsive
- Breakpoints: sm(640), md(768), lg(1024), xl(1280)
- Touch targets: minimum 44px height/width
- Grid layouts: 1-col mobile, 2-col tablet, 3-col desktop
- Bottom nav on mobile for primary actions

### Accessibility Standards
- Keyboard navigation for all interactive elements
- Visible focus rings (2px offset, brand color)
- Semantic HTML (header, main, nav, landmarks)
- ARIA labels for icon-only buttons
- Live regions for dynamic content (toasts, streaming updates)

---

## 7) Environments & Secrets

**Core env vars** (examples):

```
APP_URL=https://beakerai.com
RAILS_MASTER_KEY=...

# Vapi
VAPI_API_KEY=...
VAPI_WEBHOOK_SECRET=...

# Twilio
TWILIO_ACCOUNT_SID=AC...
TWILIO_AUTH_TOKEN=...
DEMO_OUTBOUND_NUMBER=+1415...

# Stripe
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
STRIPE_PRICE_STARTER=price_...

# Email
RESEND_API_KEY=re_...

# Redis/Jobs
REDIS_URL=redis://...
```

**Local dev**

* `bin/setup` provisions DB, seeds scenario templates, starts Sidekiq.
* Use fixture payloads to simulate Vapi/Stripe webhooks in dev.

---

## 8) Security, Privacy, Compliance (MVP)

* Magic-link signup logs **marketing consent**; trial and hosted forms log **call consent**.
* Outbound guardrails: quiet hours, DNC list, per-minute/daily caps.
* Recording disclosure on by default (configurable per Business).
* Webhooks: token/HMAC verification; idempotent via `webhook_events`.
* Retention: trial transcripts/recordings auto-redacted after 7 days; paid retention configurable.
* Logs: emails/phones redacted; transcripts never logged.

---

## 8.5) Compliance Messaging in Product (Copy Templates)

### Trial Consent Checkbox
```
☑ I agree to receive an automated test call for demonstration purposes.
   This call will follow TCPA guidelines (8am-9pm your local time).
```

### Hosted Lead Form Consent
```
☑ I agree to receive a call from [Business Name] about my inquiry.
   Calls are placed during business hours in your timezone.
```

### Agent First Message (Recording Disclosure)
```
"Hi, this is [Agent Name] from [Business Name]. This call may be recorded 
for quality and training purposes. How can I help you today?"
```

These templates are legally reviewed and build trust while covering compliance requirements.

---

## 8.6) Operational Runbooks (Critical Procedures)

### Backup & Restore Strategy

**Automated Backups:**
```bash
# Heroku Postgres (PGBackups)
heroku pg:backups:schedule DATABASE_URL --at '02:00 America/New_York'

# Retention: 7 daily, 4 weekly, 12 monthly
# Before migrations: heroku pg:backups:capture
```

**Quarterly Restore Drill** (30-minute SLA):
```bash
#!/bin/bash
# scripts/restore_drill.sh

# 1. Create staging DB from latest backup
heroku pg:backups:restore b001 DATABASE_URL --app beaker-staging

# 2. Verify record counts match production (within 5%)
heroku run rails runner "
  puts 'Users: ' + User.count.to_s
  puts 'Businesses: ' + Business.count.to_s
  puts 'Calls (7d): ' + Call.where('created_at > ?', 7.days.ago).count.to_s
" --app beaker-staging

# 3. Test critical flow (signup → trial → webhook)
heroku run rails test:system test/system/trial_flow_test.rb --app beaker-staging

# 4. Document restore time (target: <30min for 100GB)
echo "Restore completed at $(date)"
```

**PII Anonymization** (for non-prod environments):
```ruby
# lib/tasks/anonymize.rake
namespace :db do
  desc "Anonymize PII for staging/dev"
  task anonymize: :environment do
    User.find_each do |u|
      u.update_columns(email: "user-#{u.id}@example.test")
    end
    
    Lead.find_each do |l|
      l.update_columns(
        phone: "+1415555#{rand(1000..9999)}",
        email: "lead-#{l.id}@example.test",
        name: "Test User #{l.id}"
      )
    end
    
    Call.update_all(transcript: {}, captured: {})
    TrialCall.update_all(transcript: {}, captured: {})
    
    puts "✅ PII anonymized for #{Rails.env} environment"
  end
end
```

### Webhook Replay (For Failed Processing)

```ruby
# lib/tasks/webhooks.rake
namespace :webhooks do
  desc "Reprocess failed webhook events"
  task reprocess_failed: :environment do
    WebhookEvent.where(status: 'failed')
                .where('created_at > ?', 24.hours.ago)
                .find_each do |event|
      case event.provider
      when 'vapi'
        ProcessVapiEventJob.perform_later(event.id)
      when 'stripe'
        ProcessStripeEventJob.perform_later(event.id)
      end
      puts "Queued: #{event.provider} #{event.event_id}"
    end
  end
end
```

### Emergency Procedures

**Circuit Breaker Manual Override** (if external service is down):
```ruby
# rails console
# Temporarily disable Vapi calls if service is down
Stoplight(:vapi).lock(:red)

# Re-enable after service recovers
Stoplight(:vapi).unlock
```

**Trial Abuse Mitigation** (if spam detected):
```ruby
# rails console
# Block IP from creating trials
Rack::Attack::BlockList.add("trial_signup", "123.45.67.89")

# Remove block after investigation
Rack::Attack::BlockList.delete("trial_signup", "123.45.67.89")
```

---

### Incident Response Runbooks (Top 5 Scenarios)

**RB-01: Payment Processing Down (P0 - CRITICAL)**

*Symptoms:* No Stripe webhooks received >15min; customer reports payment not working.

*Triage (5 min):*
1. Check Stripe Dashboard → Webhooks: Are events being sent?
2. Check `/admin/webhook_events` (filter provider=stripe, status=failed)
3. Check Sidekiq: Is `ProcessStripeEventJob` queue backed up?

*Resolution:*
- **If Stripe sending but not receiving:** Verify webhook URL in Stripe settings, check HTTPS cert
- **If Rails receiving but jobs failing:** Check Sentry for `ProcessStripeEventJob` errors (likely DB/Vapi issue)
- **If queue backed up:** Scale workers temporarily, reprocess failed events via Admin panel

*Recovery:* Manually reprocess via Admin → Events → Reprocess; verify Business created; email customer.

---

**RB-02: Trial Calls Failing (Success Rate <75%)**

*Symptoms:* Trial call success rate <75% over 1 hour; TTFC SLO breached; user complaints.

*Triage (5 min):*
1. Check Vapi status page: https://status.vapi.ai
2. Check Sentry for `Vapi::ServiceUnavailable` or `StartTrialCallJob` errors
3. Check Dashboard 3: Is Vapi circuit breaker open (red)?

*Resolution:*
- **If Vapi API down:** Circuit breaker should auto-open; post status notice (Flipper flag `vapi_degraded`); queue calls for retry
- **If phone validation issue:** Check `trial_call_failed` events for `invalid_phone` errors; fix validation logic
- **If timeout:** Verify circuit breaker thresholds not too aggressive; check network

*Communication:* If >1 hour, email affected trialists: "Experiencing delays; calls will retry automatically."

---

**RB-03: Webhook Backlog (>100 Unprocessed Events)**

*Symptoms:* Dashboard 3 shows >100 unprocessed webhooks; delayed call status updates; customers not seeing transcripts.

*Triage (5 min):*
1. Check Sidekiq: Is `ProcessVapiEventJob` queue growing?
2. Check `WebhookEvent.where(status: 'received').count`
3. Check Sentry for recurring job failure pattern

*Resolution:*
- **If worker capacity:** Scale Sidekiq workers immediately
- **If job failures:** Fix root cause (DB lock? API timeout?); bulk reprocess: `WebhookEvent.where(status: 'failed').find_each { |e| ReprocessWebhookEventJob.perform_later(e.id) }`
- **If DB locks:** Kill long-running queries; add query timeouts

*Prevention:* Set worker auto-scaling based on queue depth; add webhook latency P95 alerts.

---

**RB-04: Trial Abuse Spike (Cost >$100/day)**

*Symptoms:* Vapi spend >$100/day; Dashboard 3 shows >3 trials/email or >10/hour per IP.

*Triage (3 min):*
1. Check Dashboard 3: Top abusers by normalized email/IP
2. Check `cost_per_trial` P90: Is it >$0.70?
3. Review recent trial creations: Any patterns (same domain, VPN IPs)?

*Resolution:*
- **Immediate:** Block offending IPs via `Rack::Attack::BlockList.add("trial_signup", ip)`
- **If email abuse:** Add domain to blocklist (e.g., `@tempmail.com`)
- **If persistent:** Enable hCaptcha via Flipper flag `enable_hcaptcha`

*Recovery:* Review and tighten Rack::Attack throttles; consider requiring phone verification for trials.

---

**RB-05: TCPA Quiet Hours Violation**

*Symptoms:* User complaint "Your agent called me at 5 AM!"; potential legal exposure.

*Triage (IMMEDIATE):*
1. **Kill switch:** Disable outbound calling via Flipper flag `speed_to_lead_enabled = false`
2. Check `audit_logs` for `call_blocked_compliance` events: Are they firing correctly?
3. Check `PhoneTimezone.lookup(phone)`: Is recipient timezone derived correctly?

*Resolution:*
- **If timezone logic broken:** Deploy fix immediately; verify with test calls to different area codes
- **If quiet hours window wrong:** Check `ComplianceSetting` for affected business; correct and redeploy
- **If bypass bug:** Review `CallPermission.check!` logic; ensure no code paths skip validation

*Legal:* Document incident (time, affected phone, root cause); consult legal if complaint escalates.

*Prevention:* Add timezone detection testing to CI; monitor `call_blocked_quiet_hours` event rate (should be >0).

---

### Weekly Ops Cadence (Solo Founder - ≤2 Hours/Week)

**Monday Morning (30 min) — Week Review:**
- [ ] Open **Dashboard 1 (Trial Funnel)** → Check 7-day Trial→Paid conversion (>15%?)
- [ ] Open **Dashboard 2 (Paid Health)** → Check MRR trend, Weekly Active Businesses (>70%?)
- [ ] Open **Dashboard 3 (Compliance & Errors)** → Check circuit breaker status, webhook failures, abuse metrics
- [ ] Review Slack `#ops-alerts` for past 7 days → Any recurring patterns?

**Tuesday (15 min) — Cost Review:**
- [ ] Check Vapi/Twilio spend month-to-date vs. budget
- [ ] Review `cost_per_trial` P90 (alert if >$0.70)
- [ ] Check Dashboard 3 for trial abuse (auto-blocks working?)

**Wednesday (15 min) — Customer Health:**
- [ ] Identify businesses with 0 calls in 7 days (churn risk) → Send proactive email
- [ ] Review any customer support emails

**Thursday (15 min) — System Health:**
- [ ] Spot-check analytics accuracy (pick 1 business, verify dashboard vs. SQL)
- [ ] Check Sentry for top 3 errors → Prioritize for next sprint

**Friday (30 min) — Planning:**
- [ ] Review feature flag usage → Any experiments ready to ship/kill?
- [ ] Update runbooks if new incidents occurred
- [ ] Celebrate wins: Revenue growth? Positive feedback?

**Monthly (1st of month, 60 min) — Deep Dive:**
- [ ] Run backup restoration test (Section 8.6)
- [ ] Review Audit Logs for admin actions
- [ ] Review cost optimization opportunities (unused Twilio numbers, orphaned recordings)
- [ ] Send monthly summary to self: MRR, churn, top 3 wins, top 3 issues

**Automation Reduces Manual Work:**
- `TrialAbuseMonitorJob` (hourly) → Auto-blocks abusers, no manual intervention
- `DataRetentionJob` (daily) → Auto-purges expired data
- `DailyReportJob` (8am local) → Emails customers automatically
- Sentry/Slack alerts → Only pings for actionable issues

---

## 8.7) Tripwire Alerts (Sentry/Monitoring Configuration)

**Purpose:** Early warning system for critical failures. Configure these alerts in Sentry/monitoring BEFORE launch. Each alert should ping Slack/email with runbook link.

**Critical Alerts (Configure Pre-Launch):**

| Alert | Threshold | Severity | Action |
|-------|-----------|----------|--------|
| `call_blocked_quiet_hours` event == 0 | 24 hours | CRITICAL | Indicates quiet hours bypass bug (RB-05) |
| Trial cost P90 | >$0.70 (investigate), >$1.00 (CRITICAL) | HIGH | Trial abuse or vendor price increase (RB-04) |
| Trials per normalized email | >3/day | MEDIUM | Auto-block should be firing; verify config |
| Trials per IP | >10/hour | MEDIUM | Auto-block should be firing; verify config |
| Circuit breaker trips | >3 in 24h | HIGH | Vapi/Stripe/Twilio degradation (RB-02) |
| Webhook backlog | >100 unprocessed events | HIGH | Worker capacity or job failure (RB-03) |
| Trial→Paid conversion | <10% after 100 trials | MEDIUM | Pivot signal; review mini-report UX |
| `ActiveRecord::RecordNotUnique` | Outside planned rescue blocks | CRITICAL | Race condition not handled properly |
| Webhook processing latency P95 | >10s | MEDIUM | Job queue backlog or performance issue |
| TTFC P95 | >10s | MEDIUM | Vapi performance or network issue |
| Daily Vapi spend | >$100 | CRITICAL | Cost overrun; investigate immediately (RB-04) |

**Alert Configuration Examples:**

```ruby
# config/initializers/sentry.rb
Sentry.init do |config|
  config.before_send = lambda do |event, hint|
    # Alert on RecordNotUnique outside planned rescues
    if event.exception.is_a?(ActiveRecord::RecordNotUnique)
      # Check if in expected rescue context
      unless event.transaction&.include?('ProcessVapiEventJob') || 
             event.transaction&.include?('Leads::Upsert')
        # Send alert to Slack
        SlackNotifier.alert("Unhandled race condition: #{event.transaction}")
      end
    end
    event
  end
end
```

**Monitoring Dashboard Widgets (Recommended):**
- Circuit breaker status (Vapi, Stripe, Twilio): Green/Red indicator
- Webhook backlog: Real-time count with 7-day trend
- Trial abuse metrics: Emails/IP throttles with auto-block count
- Cost tracking: Daily Vapi/Twilio spend vs budget

**Weekly Review (Monday):** Check alert history for patterns; update thresholds as needed; document new incidents in runbooks.

---

## 9) Roadmap (Phases)

* **Phase 0** — Foundations (Rails spine, auth, security baseline).
* **Phase 1** — Trial with magic-link auth, personalized outbound call, caps, quiet hours, abuse prevention.

### Trial Abuse Prevention (P1-13)
Without controls, trial farming creates cost exposure:
- 3 calls × $0.10/min × 120s = ~$0.60/trial
- At 1,000 trials/month with 10% abuse = $600/month burn

**Controls (Layered Defense):**

1. **Email normalization** (Gmail +trick and dot removal)
   ```ruby
   # app/services/email_normalizer.rb
   normalized = email.downcase.strip
   if normalized.end_with?('@gmail.com')
     local, domain = normalized.split('@')
     local = local.split('+').first.gsub('.', '')  # Remove + suffix and dots
     normalized = "#{local}@#{domain}"
   end
   ```

2. **IP-based rate limiting** (10 trials/10min, 3 trials/day per email)
   ```ruby
   # config/initializers/rack_attack.rb
   throttle('trials/ip', limit: 10, period: 10.minutes) do |req|
     req.ip if req.path == '/trial_sessions' && req.post?
   end
   
   throttle('trials/email', limit: 3, period: 1.day) do |req|
     if req.path == '/trial_sessions' && req.post?
       email = req.params['email']
       Digest::SHA256.hexdigest(EmailNormalizer.normalize(email)) if email
     end
   end
   ```

3. **hCaptcha** (optional, flag-gated via Flipper `enable_hcaptcha`)

4. **Phone validation** (E.164 format enforcement + basic VoIP detection)

**Automated Response (No Manual Intervention):**

```ruby
# app/jobs/trial_abuse_monitor_job.rb (runs hourly)
class TrialAbuseMonitorJob < ApplicationJob
  def perform
    # Auto-block IPs with >10 trials in 1 hour
    abusive_ips = TrialSession
      .where('created_at > ?', 1.hour.ago)
      .group(:ip_address)
      .having('COUNT(*) > 10')
      .pluck(:ip_address)
    
    abusive_ips.each do |ip|
      Rack::Attack::BlockList.add("trial_signup", ip)
      Sentry.capture_message("Auto-blocked IP for trial abuse: #{ip}")
    end
    
    # Auto-block emails with >3 trials in 24h
    abusive_emails = TrialSession
      .where('created_at > ?', 24.hours.ago)
      .group(:email_normalized)
      .having('COUNT(*) > 3')
      .pluck(:email_normalized)
    
    abusive_emails.each do |email_hash|
      # Store in DB to persist across restarts
      AbuseList.find_or_create_by!(
        type: 'email_hash',
        value: email_hash,
        reason: 'trial_farming',
        auto_blocked_at: Time.current
      )
    end
  end
end
```

**Monitoring Metrics (Dashboard 3):**
- Trials created per normalized email (auto-block at >3/day, alert at >5/day)
- Trials created per IP (auto-block at >10/hour, alert at >15/hour)
- Cost per trial P90 (alert if >$0.70; CRITICAL alert if >$1.00)
- Trial abuse rate (% auto-blocked trials, target <5%)
- Auto-block effectiveness (cost savings estimate)

* **Phase 2** — Vapi webhooks + **trial mini-report (THE conversion moment)** + real-time updates + concurrency fixes.

**⚠️ CRITICAL — Mini-Report as Conversion Driver:**

The mini-report is where users convert. It is THE emotional "aha moment" that drives 80% of upgrade decisions. This is not "just another view"—it is the most important UI in the entire application.

**Non-Negotiable Requirements:**
- Display captured fields FIRST (above transcript) — this proves the agent worked
- Show recording with prominent play button (≥60px tap target on mobile)
- Include intent badge (lead_intake/scheduling/info) to demonstrate understanding
- Load in <3s after call ends (Webhook→UI latency SLO)
- Work flawlessly on mobile (375px width) — HVAC contractors use phones
- Real-time appearance (no page refresh) via Turbo Stream

**Prioritization:** Prioritize mini-report perfection over all other Phase 2 UI work. The rest of the trial page can be basic; the mini-report must be exceptional.
* **Phase 3** — Stripe conversion → Business + paid assistant, onboarding email.
* **Phase 4** — **Admin panel (P4-01, ships FIRST)** + Assign Twilio number + paid dashboard (live calls).

**Why Admin Ships First:** The first conversion failure or webhook processing error requires immediate diagnosis. Without admin tools, debugging requires SSH/console access and delays customer support by hours. Admin panel enables:
- Webhook event inspection and manual reprocessing
- Business/User/Lead record search
- DNC list management
- Sidekiq queue monitoring
- Trial expiration overrides

* **Phase 4.5** — ⚠️ RUNS IN PARALLEL WITH PHASE 4: Guardrails, consent, DNC, retention, compliance.

**TCPA Compliance Detail:**
Quiet hours MUST use recipient's timezone (derived from phone area code), NOT business timezone.
- ❌ Wrong: NYC business calls LA lead at 8:30 AM EST (5:30 AM PST) = violation
- ✅ Right: System checks recipient's local time (area code → timezone lookup)
- Penalty: $500-$1,500 per violation
* **Phase 5** — Scenario engine (paid) + hosted lead form + Speed-to-Lead + timezone-aware quiet hours.
* **Phase 6** — Analytics & reporting (tiles, charts, daily email) + lightweight Admin features.

---

## 10) Engineering Principles

* **User-first speed:** optimize time-to-first-call and time-to-value; graceful fallback > perfect prompt.
* **Async by default:** external calls from jobs; webhook controllers ACK fast and enqueue work.
* **Idempotency everywhere:** unique keys on webhooks/calls; conversion guarded by unique subscription/session.
* **Bounded complexity:** adapters for Vapi/Twilio/Stripe; pure POROs for prompts/analytics.
* **Observability:** SLOs on webhook processing latency; Sentry; structured logs.
* **Test what breaks revenue:** webhook idempotency > unit coverage; TCPA compliance > styling tests; request specs > unit mocks (see Section 12).

---

## 10.5) UI/UX Definition of Done

Every UI-related ticket (views, components, interactions) must meet these standards before merging:

**Functionality:**
- [ ] Mobile-first ENFORCED: All interactive flows tested at 375px in Chrome DevTools
- [ ] Works on desktop (1024px+ tested)
- [ ] Touch targets verified: All buttons/links ≥44px height AND width
- [ ] Bottom navigation present on mobile for primary actions (trial flow, dashboard)
- [ ] Horizontal scroll test: 0 horizontal scrollbars at 375px, 768px, 1024px viewports
- [ ] Mini-report mobile test: Captured fields visible above fold, play button ≥60px tap target
- [ ] All interactive states implemented (default, hover, focus, active, disabled, loading, error)
- [ ] Loading states prevent layout shift (skeletons or reserved heights)
- [ ] Error states show actionable messages with retry/dismiss options

**Accessibility:**
- [ ] Keyboard navigable (tab order logical, focus visible with 2px ring)
- [ ] Semantic HTML (`<button>` not `<div onclick>`, headings in order)
- [ ] ARIA labels on icon-only buttons and controls
- [ ] Color contrast meets WCAG 2.1 AA (4.5:1 text, 3:1 UI)
- [ ] Forms have associated `<label>` elements (not placeholder-only)

**Components:**
- [ ] ViewComponent created (not raw ERB) if reused 2+ times
- [ ] ViewComponent::Preview includes all states (default, loading, error, edge cases)
- [ ] Component uses design tokens (no inline hex colors)
- [ ] Props validated and documented in component class

**Code Quality:**
- [ ] No raw Tailwind classes in feature templates (use ViewComponents)
- [ ] Stimulus controllers under 100 lines; single responsibility
- [ ] No `!important` in CSS (fix specificity issues)
- [ ] Responsive classes mobile-first (`class="text-sm md:text-base"`)

**Testing:**
- [ ] System spec covers happy path (click through entire flow)
- [ ] Component spec tests all variants/slots
- [ ] Accessibility: `axe-core` assertions pass (via axe-rspec)
- [ ] Performance: CLS <0.02 on pages with dynamic content

**Documentation:**
- [ ] Complex interactions documented (e.g., Turbo Stream flow diagrams)
- [ ] Copy/microcopy finalized (no Lorem Ipsum in production)
- [ ] Screenshots added to PR for visual review

---

## 10.6) Pre-Launch Validation (Week 1-2, Before Phase 1 Ships)

**Objective:** Validate demand with ONE ICP (HVAC) using $200 budget BEFORE building full Phase 1.

### Budget Allocation ($200 Total)

* **$0:** Manual prospect scraping (Yelp, Google My Business, LinkedIn)
* **$49:** Prospecting tool (Apollo.io or Hunter.io, 1 month)
* **$20:** Domain + DNS (if not already owned)
* **$40:** Email warmup + tracking domain setup
* **$50:** Facebook/Instagram ads (micro-budget test)
* **$41:** Buffer (Loom Pro, Canva assets, misc)

### Week 1-2 Activities (Before Writing Code)

**Day 1-2: ICP Research**
* Scrape 200 HVAC contractors (1-5 employees, emergency services)
* Filter: (1) Has website, (2) Shows after-hours number or "24/7", (3) <50 employees
* Tools: GMB scraper, Yelp API, LinkedIn Sales Navigator trial
* Output: CSV with name, email, phone, website, city

**Day 3-5: Positioning & Messaging**
* Write positioning doc (Section 2.5 as template)
* Create 3 email templates (see Campaign 1 below)
* Record 90-second Loom: "This AI called me at 2 AM and sounded human"
* Build simple landing page (Carrd.co, $19/year) with trial signup form

**Day 6-10: Manual Outreach (100 Emails)**
* Send 10 personalized emails/day to top 100 prospects
* Subject: "Lose a customer last night?" (high open rate)
* Body: Pain (missed calls) → Solution (AI demo) → CTA (call yourself)
* Track: Opens (email tracker), replies, trial signups

**Day 11-14: Paid Validation ($50 Facebook Ads)**
* Audience: Business owners, 30-60, interests: HVAC, plumbing, emergency services
* Creative: 30-second video of trial experience (record manually)
* Goal: 50 clicks → 5 landing page visits → 1 email signup
* Learn: Which pain point resonates (speed vs after-hours vs missed calls)

### Campaign 1: Cold Email Template (HVAC)

```
Subject: Lose a customer last night?

Hi [FIRST_NAME],

I looked up [BUSINESS_NAME] and saw you offer emergency service.

Quick question: What happens when someone calls at 2 AM and you're asleep?

Most HVAC businesses lose 40% of after-hours calls to competitors.
That's $4,000-8,000/month in jobs you never knew about.

I built an AI that answers your phone 24/7 and books the call.
Sounds crazy, but it works.

Want to hear it? → [LINK - it calls you in 60 seconds]

No demo. No sales call. Just call yourself.

[YOUR_NAME]
Beaker AI
```

**Success Metrics:**
* 10% open rate (10 opens)
* 5% reply rate (5 responses)
* 3 say "I'd try this"
* 1 completes trial demo

### Exit Criteria (Before Phase 1 Full Build)

**Minimum Viable Signal (1 week):**
- [ ] 5+ prospects responded positively to cold email
- [ ] 3+ prospects said "I'd try this" or "How much does it cost?"
- [ ] 1+ prospect completed demo call (manual Vapi setup, no automation)
- [ ] Positioning validated: Speed-to-lead angle resonates vs generic "AI receptionist"

**Strong Signal (2 weeks):**
- [ ] 10+ email responses
- [ ] 5+ trial signups (even to waitlist/manual demo)
- [ ] 1+ prospect asks "Can I pay for this now?"
- [ ] Paid ads generated 1+ qualified lead at <$50 CAC

**Weak Signal (Pivot Required):**
- [ ] <5 responses from 100 emails → ICP mismatch or messaging problem
- [ ] 0 interest in trial demo → product-market fit question
- [ ] Common objection repeated >5 times → positioning needs fixing
- [ ] Paid ads: 0 clicks or $10+ CPC → audience/creative problem

### Decision Points

**IF Strong Signal → Proceed with Phase 1 as planned**
* Build full trial automation (Phase 1)
* Expand outreach to 500 prospects
* Allocate next $500 to paid acquisition

**IF Minimum Signal → Iterate messaging, try again**
* Rewrite positioning (test after-hours angle vs speed-to-lead)
* Expand to 200 more emails with new template
* Run A/B test on landing page copy

**IF Weak Signal → Pivot before building**
* Try different ICP (gym instead of HVAC)
* Or different pain point (appointment booking vs missed calls)
* Or simplify product (just inbound answering, no outbound)

### Tools & Setup (Pre-Launch)

**Email Infrastructure:**
* Warmup: Send 5-10 emails/day to personal contacts for 7 days before cold outreach
* Tracking: Use UTM params in all links (`?utm_source=coldemail&utm_medium=hvac&utm_campaign=launch`)
* Deliverability: SPF, DKIM, DMARC records configured (Section 7 env vars)

**Landing Page (Minimum Viable):**
* Headline: "Call Hot Leads in 60 Seconds, Not 60 Minutes"
* Subhead: "AI phone agent for HVAC contractors. Capture after-hours calls while you sleep."
* CTA: "Try It Free - Calls You in 60 Seconds"
* Social proof: "Answered 127 emergency calls last week" (once you have data)
* Form: Email only (magic link signup from Phase 1)

**Analytics (Free Tier):**
* Google Analytics 4: Track landing page visits, trial signups, conversions
* Ahoy (Phase 2): Server-side event tracking for trial flow
* Spreadsheet: Manual tracking of email responses, objections, feedback

This validation step de-risks the 3-6 month Phase 1-6 build by proving demand exists before investing engineering time.

---

## 11) SLIs/SLOs (MVP targets)

* **TTFA (trial agent ready):** ≤ 20s P95.
* **TTFC (call after click):** ≤ 10s P95.
* **Webhook-to-UI latency:** ≤ 3s P95.
* **Error budget:** < 1% failed trial call attempts per day.

### Operational SLOs (System Health)

| Metric | Target | P95 | Alert Threshold | Runbook |
|--------|--------|-----|-----------------|---------|
| Trial Call Success Rate | >85% | >90% | <75% for 1 hour | RB-02 |
| Webhook Processing Success | >99% | - | >5 failures/10min | RB-03 |
| Webhook Processing Latency | <2s | <5s | >10s P95 for 10min | RB-03 |
| Job Queue Depth (Sidekiq) | <50 | <200 | >500 jobs | - |
| Circuit Breaker Trips | <3/day | - | >5 trips in 24h | RB-02 |
| API Response Time (P95) | <200ms | <500ms | >1s for 10min | - |
| Database Pool Utilization | <70% | <85% | >90% for 5min | - |

### Cost & Abuse SLOs

| Metric | Target | Alert Threshold | Auto-Block | Runbook |
|--------|--------|-----------------|------------|---------|
| Cost per Trial (P90) | <$0.70 | >$1.00 | - | RB-04 |
| Trials per Email (normalized) | ≤3/day | >5/day | >3/day | RB-04 |
| Trials per IP | ≤10/hour | >15/hour | >10/hour | RB-04 |
| Daily Vapi Spend | <$20 | >$100 | - | RB-04 |
| Trial Abuse Rate | <5% | >10% | - | RB-04 |

### Compliance SLOs

| Metric | Target | Alert Threshold | Runbook |
|--------|--------|-----------------|---------|
| Call Blocked (Quiet Hours) | >0/day | 0/day (indicates bypass bug) | RB-05 |
| Call Blocked (DNC) | N/A | Manual review weekly | - |
| Consent Coverage (Trials) | 100% | <100% | - |
| Timezone Detection Accuracy | 100% | <100% (test suite) | RB-05 |

### Activation & Retention Metrics
* **Week 1 Success:** >40% of paid users complete: number assigned + lead form shared + dashboard viewed 2+ times (within 7 days)
* **Trial → Paid Conversion:** >15% (stretch: 20%)
* **D7 Retention:** >70%
* **D30 Retention:** >60%
* **M3 Retention:** >50%

### UI/UX Performance Targets

**Lighthouse Scores (Mobile, p75):**
- Performance: >90
- Accessibility: 100
- Best Practices: >95
- SEO: >90

**Core Web Vitals:**
- LCP (Largest Contentful Paint): <2.0s
- FID (First Input Delay): <100ms
- CLS (Cumulative Layout Shift): <0.02

**JavaScript Budget:**
- Initial bundle: <100KB (gzipped)
- Stimulus controllers: <5KB each
- No framework bloat (React, Vue, etc.)

**Accessibility Minimums:**
- Keyboard navigation: 100% of features operable
- Color contrast: WCAG 2.1 AA (4.5:1 text, 3:1 UI components)
- Screen reader: Semantic HTML + ARIA where needed
- Focus visible: 2px offset ring on all interactive elements

**Mobile:**
- Touch targets: >44px height/width
- Horizontal scroll: Never on any breakpoint
- Bottom nav: <60px reserved height on mobile
- Responsive images: Serve 1x/2x based on device pixel ratio

---

## 11.5) UI/UX Testing Strategy

**ViewComponent Testing:**
- Every component has `ViewComponent::Preview` with 5+ states
- Component specs test: rendering, variants, slots, accessibility attributes
- Preview gallery at `/rails/view_components` used for visual QA
- Screenshot diffs (optional: Percy, or capybara-screenshot) in CI

**Mobile Testing:**
- System specs run at 375px (iPhone SE) and 1024px (desktop)
- No horizontal scroll assertions on all screens
- Touch target size validation (>44px)

**Keyboard Navigation Testing:**
- Tab order verified for all flows (signup → trial → dashboard)
- Focus trap in modals
- Escape key closes dialogs
- Arrow keys work in audio player

**Accessibility Testing:**
- `axe-core` runs in system specs (via axe-rspec gem)
- Color contrast checked in design tokens
- ARIA labels validated
- Screen reader testing (manual, pre-launch)

**Performance Testing:**
- Lighthouse CI runs on PR (mobile score must be >90)
- CLS monitored on Turbo Stream updates (must be <0.02)
- No layout shift assertions in system specs

**Visual Regression (Optional):**
- Percy or capybara-screenshot for component previews
- Fail CI on unexpected visual changes
- Manual approval for intentional design updates

**Component Testing Matrix:**

| Component | States Tested | A11y | Keyboard | Mobile |
|---|---|---|---|---|
| Button | 5 (default, loading, disabled, hover, focus) | ✓ | ✓ | ✓ |
| Input | 4 (default, filled, error, disabled) | ✓ | ✓ | ✓ |
| CallCard | 3 (collapsed, expanded, playing) | ✓ | ✓ | ✓ |
| AudioPlayer | 4 (stopped, playing, loading, error) | ✓ | ✓ | ✓ |
| Dialog | 3 (open, closing, closed) | ✓ | ✓ | ✓ |
| Toast | 4 (success, error, warning, info) | ✓ | N/A | ✓ |

---

## 12) Test Strategy (Pragmatic, Solo-Dev Optimized)

### Philosophy: Test What Breaks Revenue or Violates Compliance

**Coverage targets are vanity metrics.** Focus on these critical paths:
1. Webhook idempotency (duplicate charges = revenue loss)
2. TCPA compliance (quiet hours violations = $500-$1,500/call)
3. Race conditions (concurrent webhooks = data corruption)
4. Trial abuse prevention ($600+/month burn without controls)
5. Payment flow (Stripe → Business conversion must be bulletproof)

### Test Pyramid (Solo Dev Edition)

```
     System (10 tests)  ← 3-5 critical user flows
   Request (30 tests)   ← Primary defense (webhooks, auth, APIs)
 Unit (20 tests)        ← Business logic only (not Rails framework)
───────────────────────────────────────────────
Total: ~60 tests/phase, <2 min suite time
```

**NOT included:** Separate E2E suite (Capybara IS your E2E), test matrices (single Ruby/PG version), flaky test infrastructure.

### Mandatory Tests Before Each Phase Ships

**Phase 0-1 (15 tests, <30s):**
- ✅ Webhook idempotency (concurrent processing, duplicate events)
- ✅ Magic-link auth (generate, validate, expire, single-use)
- ✅ Trial limits (3 calls, 120s cap, quiet hours)
- ✅ Trial abuse (email normalization, IP throttling)
- ✅ Request specs (trial creation, call trigger, dashboard auth)

**Phase 2 (20 tests, <60s total):**
- ✅ Webhook processing (Vapi call.ended, payload variants, errors)
- ✅ Race conditions (concurrent `ProcessVapiEventJob`, atomic updates)
- ✅ Real-time updates (ActionCable broadcasts, Turbo Stream prepends)
- ✅ System spec: Trial signup → call → mini-report appears

**Phase 3 (15 tests, <90s total):**
- ✅ Stripe webhook idempotency (duplicate checkout.session.completed)
- ✅ Payment flow (checkout → conversion → Business creation)
- ✅ Race condition: Concurrent `ConvertTrialToBusinessJob`
- ✅ System spec: Trial → Upgrade → Dashboard access

**Phase 4.5 (15 tests, <120s total):**
- ✅ TCPA compliance (quiet hours in RECIPIENT timezone, not business)
- ✅ DNC enforcement (CallPermission blocks DNC numbers)
- ✅ Consent logging (IP, timestamp, statement snapshot)
- ✅ Velocity caps (per-minute, daily limits via Redis)

**Phase 5 (10 tests):**
- ✅ Speed-to-lead flow (form → job → call → dashboard)
- ✅ Lead deduplication (phone/email normalization)
- ✅ Quiet hours upgrade (recipient timezone via PhoneTimezone.lookup)

**Phase 6 (10 tests):**
- ✅ Analytics computation (percentiles, formulas, date ranges)
- ✅ Performance regression (dashboard <500ms with 50 calls)
- ✅ CSV export streams (no memory bloat on 10k+ records)

### Critical Test Examples (Copy-Paste Ready)

**1. Webhook Idempotency (Concurrent Processing):**
```ruby
# spec/jobs/process_vapi_event_job_spec.rb
it "handles concurrent webhook processing without duplicates" do
  event = create(:webhook_event, event_id: "evt_123")
  
  # Simulate two webhooks arriving simultaneously
  threads = 2.times.map do
    Thread.new { ProcessVapiEventJob.perform_now(event.id) rescue nil }
  end
  threads.each(&:join)
  
  # Database constraint prevents duplicates
  expect(Call.where(vapi_call_id: "call_123").count).to eq(1)
  expect(event.reload.status).to eq("processed")
end
```

**2. TCPA Quiet Hours (Recipient Timezone):**
```ruby
# spec/services/call_permission_spec.rb
it "enforces quiet hours in RECIPIENT timezone, not business" do
  la_phone = "+13105551234"  # Los Angeles (PST)
  
  # 8:00 AM EST = 5:00 AM PST (VIOLATION!)
  travel_to Time.zone.parse("2025-10-25 08:00:00 EST") do
    result = CallPermission.check(business: business, to_e164: la_phone, context: {})
    expect(result.ok).to be false
    expect(result.reason).to eq("quiet_hours")
  end
end
```

**3. Race Condition (Payment Conversion):**
```ruby
# spec/jobs/convert_trial_to_business_job_spec.rb
it "creates exactly one Business when webhook retries" do
  trial = create(:trial_session)
  
  # Stripe webhook arrives twice (network retry)
  2.times do
    ConvertTrialToBusinessJob.perform_now(
      user_id: trial.user_id,
      trial_session_id: trial.id,
      stripe_subscription_id: "sub_123"
    )
  end
  
  # Unique constraints prevent duplicates
  expect(Business.where(trial_session_id: trial.id).count).to eq(1)
  expect(Business.where(stripe_subscription_id: "sub_123").count).to eq(1)
end
```

**4. Trial Abuse Prevention:**
```ruby
# spec/services/email_normalizer_spec.rb
it "prevents Gmail +trick and dot abuse" do
  expect(EmailNormalizer.normalize("user+trial1@gmail.com")).to eq("user@gmail.com")
  expect(EmailNormalizer.normalize("u.s.e.r@gmail.com")).to eq("user@gmail.com")
end

# spec/requests/trial_sessions_spec.rb
it "blocks IP after 10 trials/hour" do
  10.times { post trial_sessions_path, params: valid_params }
  
  post trial_sessions_path, params: valid_params
  expect(response).to have_http_status(:too_many_requests)
end
```

**5. Performance Regression (SLO Enforcement):**
```ruby
# spec/performance/dashboard_spec.rb
it "loads dashboard in <500ms with realistic data" do
  business = create(:business)
  create_list(:call, 50, business: business)
  create_list(:lead, 30, business: business)
  sign_in business.user
  
  benchmark = Benchmark.measure do
    get business_dashboard_path(business)
  end
  
  expect(benchmark.real).to be < 0.5  # 500ms SLO
end
```

### External Service Mocking (VCR + WebMock)

**VCR Setup (Record Once, Replay Forever):**
```ruby
# spec/support/vcr.rb
VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock
  c.default_cassette_options = {
    record: :once,
    re_record_interval: 90.days  # Quarterly re-record
  }
  
  # Filter secrets
  c.filter_sensitive_data('<VAPI_API_KEY>') { ENV['VAPI_API_KEY'] }
  c.filter_sensitive_data('<STRIPE_SECRET_KEY>') { ENV['STRIPE_SECRET_KEY'] }
end
```

**Webhook Fixtures (Not VCR):**
```ruby
# Store in spec/fixtures/webhooks/vapi/call_ended.json
# Load and POST in request specs:
payload = file_fixture("webhooks/vapi/call_ended.json").read
post webhooks_vapi_path, params: payload, headers: { ... }
```

### Test Infrastructure (Minimal)

**FactoryBot Patterns:**
```ruby
# Use traits for states, not separate factories
factory :trial_session do
  user
  calls_used { 0 }
  
  trait :expired do
    expires_at { 1.hour.ago }
  end
  
  trait :limit_reached do
    calls_used { 3 }
  end
end

# Use build_stubbed for fast unit tests (no DB writes)
session = build_stubbed(:trial_session, calls_used: 3)
expect(session.exceeds_trial_limit?).to be true
```

**Database Cleaning:**
```ruby
# Use transactions by default (fast)
RSpec.configure do |config|
  config.use_transactional_fixtures = true
  
  # Use truncation ONLY for system specs with JS
  config.before(:each, type: :system) do
    DatabaseCleaner.strategy = :truncation
  end
end
```

**Time Control (Critical for TCPA Tests):**
```ruby
# Use ActiveSupport::Testing::TimeHelpers
travel_to Time.zone.parse("2025-10-25 21:05:00 EST") do
  expect(QuietHours.allow?(phone)).to be false
end
```

### CI Configuration (Minimal, Fast)

```yaml
# .github/workflows/ci.yml
jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16  # Single version only
      redis:
        image: redis:7
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.3'  # Single version only
          bundler-cache: true
      - run: bin/rails db:schema:load
      - run: bundle exec rspec --tag ~flaky  # Skip known flakes
      - uses: codecov/codecov-action@v3
```

**No matrix. No parallelization initially. Add when suite >5 min.**

### What NOT to Test (Anti-Patterns)

**❌ Skip These:**
- Basic Rails associations (`belongs_to :user`)
- Simple validations (`validates :email, presence: true`)
- Framework behavior (already tested by Rails)
- Getter/setter methods
- Database column existence
- Trivial enum definitions

**✅ DO Test These:**
- Custom business logic methods
- Complex scopes powering dashboards
- State machine transitions
- Service objects and policies
- Webhook processing end-to-end
- Authorization (who can access what)

### Flaky Test Policy

**Simple 3-step process:**
1. Tag flaky tests: `it "updates dashboard", :flaky do`
2. Skip in CI: `bundle exec rspec --tag ~flaky`
3. Fix within 1 week or delete

**No auto-detection, no quarantine infrastructure, no separate jobs.**

### Performance Monitoring in Tests

**Bullet (N+1 Detection):**
```ruby
# config/environments/test.rb
Bullet.enable = true
Bullet.raise = true  # Fail specs on N+1

# This will catch:
Call.all.each { |call| call.business.name }  # N+1!

# Fix with:
Call.includes(:business).each { |call| call.business.name }  # ✅
```

### Test Suite Health Targets

**Green Flags:**
- ✅ Suite runs in <2 min locally, <5 min in CI
- ✅ <5% flaky tests (fix or delete immediately)
- ✅ All critical paths have request/system specs
- ✅ Webhook idempotency tested with concurrent threads
- ✅ TCPA compliance tested with recipient timezones

**Red Flags (Investigate):**
- 🚨 Suite takes >10 minutes
- 🚨 >10% tests are flaky
- 🚨 System tests take >1 min each
- 🚨 CI fails intermittently without code changes
- 🚨 Developers skip running tests locally (too slow)

### Contract Tests for External APIs

**Validate schemas haven't changed:**
```ruby
# spec/contracts/vapi_contract_spec.rb
it "validates webhook schema" do
  payload = file_fixture("webhooks/vapi/call_ended.json").read
  
  expect(JSON.parse(payload)).to include(
    "type" => "call.ended",
    "call" => hash_including(
      "id" => be_a(String),
      "status" => be_a(String),
      "transcript" => be_a(String)
    )
  )
end
```

**Re-record VCR cassettes quarterly:**
```bash
# Delete old cassettes
rm spec/vcr_cassettes/vapi/*.yml

# Run with real API
VCR_RECORD_MODE=all bundle exec rspec spec/services/vapi_client_spec.rb

# Commit updated cassettes
git add spec/vcr_cassettes/
git commit -m "chore: re-record Vapi cassettes Q4 2025"
```

### Compliance Test Suite (Dedicated)

**Create `spec/compliance/` directory for audit-critical tests:**
```ruby
# spec/compliance/tcpa_spec.rb
describe "TCPA Compliance Audit" do
  it "never calls DNC numbers" do
    lead = create(:lead, phone: "+15551234567")
    create(:dnc_number, business: lead.business, phone_e164: lead.phone)
    
    expect {
      SpeedToLeadJob.perform_now(lead.business_id, lead.id)
    }.to raise_error(/DNC blocked/i)
  end
  
  it "logs all call consents with IP and timestamp" do
    expect {
      post lead_forms_path(slug), params: { phone: "+15551234567", consent: true }
    }.to change { Consent.count }.by(1)
    
    consent = Consent.last
    expect(consent.ip).to be_present
    expect(consent.consented_at).to be_present
    expect(consent.channel).to eq("phone")
  end
end
```

---

## 12.5) Quick Reference: "Can I Ship This?" Test Checklist

**Before merging any PR, confirm these tests exist:**

**For Controllers/Endpoints:**
- [ ] Request spec with auth guard (unauthenticated → redirect/401)
- [ ] Request spec with authorization (other user's resource → 403)
- [ ] Happy path (200/201 response, correct JSON/HTML)
- [ ] Error cases (400/422 with validation errors)

**For Background Jobs:**
- [ ] Job spec with mocked external services (VCR/WebMock)
- [ ] Idempotency test (run twice, create once)
- [ ] Retry behavior (transient error → succeeds on retry)
- [ ] Error handling (permanent error → marks failed, doesn't retry forever)

**For Webhooks (CRITICAL):**
- [ ] Signature/token verification test (invalid → 401)
- [ ] Idempotency test (same payload twice → 200 both times, one record)
- [ ] Concurrent processing test (threads, database constraint prevents duplicates)
- [ ] Fast ACK (returns 200, enqueues job, <50ms response time)
- [ ] Contract test (payload schema matches fixture)

**For Services with Business Logic:**
- [ ] Unit test for core logic (no DB, no HTTP)
- [ ] Edge cases (nil values, empty arrays, boundary conditions)
- [ ] Error handling (raise meaningful errors, not generic exceptions)

**For Compliance Features (TCPA, DNC):**
- [ ] Quiet hours in RECIPIENT timezone (not business)
- [ ] DNC check prevents call (raises appropriate error)
- [ ] Consent logged with IP + timestamp
- [ ] Audit event created for blocked calls

**For Performance-Critical Paths:**
- [ ] Bullet passes (no N+1 queries)
- [ ] Benchmark test (<500ms for dashboard with 50 records)
- [ ] Database query count test (constant regardless of data volume)

**Skip These (Don't Waste Time):**
- ❌ Testing `belongs_to :user` associations
- ❌ Testing `validates :email, presence: true` (unless custom logic)
- ❌ Testing Rails framework behavior
- ❌ Testing CSS classes or styling
- ❌ Testing every possible UI state in system specs

**When in Doubt:**
- Write a request spec (integration) before a unit spec
- Mock external APIs always (use VCR for real responses)
- Test the behavior users/webhooks see, not implementation details
- If it can cause revenue loss or compliance violations, write the test
- If test takes >1 second, you're testing the wrong layer

---

## 12.6) How to Contribute (practical notes)

* Prefer small PRs with tests (request > unit > system).
* Use VCR/WebMock for external APIs; fixtures for webhooks.
* Keep prompt packs as versioned `scenario_templates` seeds; changes require version bump.
* Add indices early; use UUIDs; avoid N+1 via includes.
* Run `bundle exec rspec` before every commit (should be <2 min).
* Tag flaky tests immediately; fix within 1 week or delete.
* Follow the "Can I Ship This?" checklist (Section 12.5) for every PR.

---

## 13) Open Questions / Next Up

* Calendar booking integration (Cal.com/Google) to replace simulated scheduling.
* ~~Better local-time detection for quiet hours~~ → **RESOLVED**: Use phone area code mapping (see Phase 5).
* Number pooling for trials (cost control) vs dedicated demo numbers.
* Self-serve number porting & routing rules.

---

## 13.5) Phase 7+ Backlog (Explicitly Deferred from MVP)

The following features are intentionally deferred until post-MVP based on product analysis review. This section consolidates all items marked **[PHASE 7+]** and **[POST-LAUNCH]** throughout the document.

### Phase 7+ Features
* **Add-Ons** (Section 3.5): Extra phone numbers, custom voice cloning, compliance pack, calendar integrations
* **Multi-channel expansion** (SMS, web chat) - Focus on voice excellence first; premature diversification dilutes quality
* **Weekly activity digest** - Daily report (Phase 6) is sufficient; adding weekly creates email fatigue
* **Referral program** - Launch only after M3 retention >50%; can't refer what doesn't retain
* **ROI calculator widget** - Requires user input (avg deal value) which creates friction; show absolute numbers instead
* **Calendar booking integration** - Phase 5 simulated scheduling is sufficient for MVP validation

### Post-Launch Features (Build After 10-50 Customers)
* **Enterprise tier** (Section 3.5): Unlimited calls, custom integrations, multi-user access, API, white-label
* **Stripe usage metering** (Section 3.5): Metered billing and overage tracking (Phase 6 when customers approach caps)
* **Advanced analytics** (Phase 6): Percentile calculations (P50, P90), cohort retention curves, segment breakdowns
* **CSV exports** (Phase 6): Build when customers request it; simple copy-paste from dashboard sufficient initially
* **30-day trend charts** (Phase 6): Start with 7-day tiles only; add charts when data volume justifies
* **Secondary ICP scenarios** (Section 1.5): Gym and dental templates (clone HVAC after validation)

### Why These Are Deferred
Each adds complexity without materially improving the core job-to-be-done: proving an AI agent can handle calls and capture leads. Ship the core, measure retention, then expand. Focus engineering time on the trial conversion moment and first 10 customers before expanding features.

---

## 13.6) Critical Risks & Mitigation

| Risk | Probability | Impact | Mitigation Strategy |
|------|-------------|--------|---------------------|
| **Webhook race conditions** create duplicate records/charges | Medium | High | Database unique constraints + with_lock + idempotency keys (Phase 2 mandatory) |
| **Trial feels generic/broken** | Medium | High | Rigorous QA on trial path; founder tests weekly; personalization validation |
| **TCPA compliance violation** | Low | Critical | Legal review before Phase 4; recipient timezone enforcement; automated guardrails |
| **Vapi/Twilio outage** | Low | High | Circuit breakers (Phase 0); graceful degradation; status page |
| **Trial abuse farming** | Medium | Medium | Email normalization + IP throttles + hCaptcha (Phase 1) |
| **Low trial conversion (<10%)** | Medium | High | A/B test mini-report design; optimize TTFC; reduce friction |
| **First conversion failure** | High | Critical | Admin panel ships FIRST in Phase 4 for immediate debugging |

**Risk Review Cadence:** Weekly during Phases 0-4; bi-weekly during Phases 5-6.

---

## 13.7) Top 5 Priority Experiments (Post-Launch)

Based on product analysis review, prioritize these experiments over others:

1. **Trial Form Friction (Phase 1)**
   - A/B test: Minimal form (business type only) vs. Full form (4 fields)
   - Measure: TTFC and trial completion rate
   - Hypothesis: Reducing inputs cuts TTFC by 40%

2. **Mini-Report Design (Phase 2)**
   - A/B test: Captured data prominence (top vs. bottom of report)
   - Measure: Time-to-upgrade after viewing report
   - Hypothesis: Leading with captured fields increases conversion 25%

3. **Speed Positioning (Marketing)**
   - A/B test: Homepage copy "AI Receptionist" vs. "Capture Leads in 60 Seconds"
   - Measure: Trial signup rate
   - Hypothesis: Speed messaging resonates stronger with SMB owners

4. **First Lead Celebration (Phase 5)**
   - Test: Confetti animation + congratulatory email vs. standard notification
   - Measure: D7 retention of users who capture first lead
   - Hypothesis: Celebration increases retention 15%

5. **Compliance Badge (Phase 4.5)**
   - Test: Add "TCPA Compliant" badge near consent checkbox
   - Measure: Trial completion rate and sentiment survey
   - Hypothesis: Trust signals reduce abandonment

**Run experiments in order listed.** Each requires <1 week implementation and provides actionable data for next iteration.

---

## 14) Appendix

**Glossary**

* **MLS:** Minimum Lovable Solution.
* **TTFA:** Time to First Agent (trial).
* **TTFC:** Time to First Call (after click).
* **Speed-to-Lead:** Time from lead form submit to call connect.
* **TCPA:** Telephone Consumer Protection Act (federal regulation).
* **DNC:** Do Not Call registry/list.

---

## 14.5) Quick Reference: Critical Implementation Patterns

### Race Condition Prevention
```ruby
# Atomic upsert (preferred)
Lead.create_with(name: name).find_or_create_by!(business_id: bid, phone: phone)

# Webhook idempotency
begin
  trial_call.save!
rescue ActiveRecord::RecordNotUnique
  trial_call = TrialCall.find_by!(vapi_call_id: vapi_call_id)
end

# Database constraints (ultimate arbiter)
add_index :leads, [:business_id, :phone], unique: true
```

### Circuit Breakers
```ruby
# External API wrapper
circuit_breaker.run { HTTP.timeout(5).post(url, json: payload) }
rescue Stoplight::Error::RedLight
  raise ServiceUnavailableError
```

### TCPA Compliance
```ruby
# Recipient timezone (NOT business timezone)
recipient_tz = PhoneTimezone.lookup(lead.phone)
quiet_hours_ok = QuietHours.allow?(recipient_tz, Time.current)

# DNC check before every outbound
raise "DNC blocked" if DncNumber.exists?(phone: phone)
```

### Webhook Processing
```ruby
# Fast ACK pattern (controller)
event = WebhookEvent.idempotent_create(provider:, payload:)
ProcessWebhookJob.perform_later(event.id)
head :ok

# Idempotent job
return if webhook_event.status == "processed"
webhook_event.with_lock { process_event_logic }
```

### Stripe Metered Billing & Usage Tracking

**Store metered subscription item ID:**
```ruby
# In ConvertTrialToBusinessJob (Phase 3)
# After creating Stripe subscription, extract and store metered item ID
subscription = Stripe::Subscription.retrieve(stripe_subscription_id, {
  expand: ['items']
})
metered_item = subscription.items.data.find { |i| 
  i.price.recurring&.usage_type == 'metered' 
}
business.update!(stripe_metered_item_id: metered_item&.id)
```

**Report usage from webhooks:**
```ruby
# In ProcessVapiEventJob (paid calls only, not trial)
def report_stripe_usage(business, call)
  return unless business.stripe_metered_item_id.present?
  
  Stripe::SubscriptionItem.create_usage_record(
    business.stripe_metered_item_id,
    quantity: 1,
    timestamp: call.created_at.to_i,
    action: 'increment',
    idempotency_key: "call_#{call.id}"  # Prevent duplicate reporting
  )
rescue Stripe::InvalidRequestError => e
  # Log but don't fail webhook processing
  Sentry.capture_exception(e, extra: { call_id: call.id })
end
```

**Enable Stripe Tax (required for compliance):**
```ruby
# In StripeCheckoutController#create
Stripe::Checkout::Session.create(
  customer: customer_id,
  mode: 'subscription',
  line_items: [{ price: price_id, quantity: 1 }],
  automatic_tax: { enabled: true },  # Critical: handles US sales tax & EU VAT
  success_url: success_url,
  cancel_url: cancel_url
)
```

**Usage calculation (for alerts):**
```ruby
# In Business model or service
def calls_this_month
  # Count calls since current billing period start
  billing_period_start = stripe_current_period_start || created_at.beginning_of_month
  calls.where('created_at >= ?', billing_period_start).count
end

def overage_amount_cents
  overage_calls = [calls_this_month - included_calls, 0].max
  overage_calls * overage_rate_cents
end

def usage_percentage
  (calls_this_month.to_f / included_calls * 100).round
end
```

**Race condition prevention for concurrent webhooks:**
```ruby
# Use Postgres advisory lock on stripe_subscription_id
Business.with_advisory_lock("stripe_sub_#{subscription_id}") do
  # Conversion or usage reporting logic
end
```

### Performance
```ruby
# Connection pool (database.yml)
pool: <%= ENV.fetch("RAILS_MAX_THREADS", 10) %>
checkout_timeout: 5
reaping_frequency: 10

# Partial indexes (migrations)
add_index :businesses, :id, where: "status = 'active'", algorithm: :concurrently

# N+1 prevention (eager loading)
Business.includes(:calls, :leads).where(status: 'active')
```

### Critical Test Patterns (See Section 12 for complete examples)
```ruby
# Webhook idempotency (concurrent processing)
threads = 2.times.map { Thread.new { ProcessVapiEventJob.perform_now(event_id) rescue nil } }
threads.each(&:join)
expect(Call.count).to eq(1)

# TCPA quiet hours (recipient timezone)
travel_to Time.zone.parse("2025-10-25 21:00:00 EST") do
  expect(CallPermission.check(to_e164: "+12125551234").ok).to be false
end

# Trial abuse prevention
expect(EmailNormalizer.normalize("user+1@gmail.com")).to eq("user@gmail.com")

# Performance regression
benchmark = Benchmark.measure { get dashboard_path }
expect(benchmark.real).to be < 0.5
```

---

# Architecture at a Glance

* **Rails 7.1 / Ruby 3.3** monolith
* **Postgres** (JSONB for templates/KB; strict indexing)
* **Redis** (Sidekiq + ActionCable)
* **Hotwire** (Turbo + Stimulus) for realtime demo page & dashboard
* **Auth**: Devise (passwordless magic links)
* **Payments**: Stripe Checkout + Webhooks
* **Voice**: Vapi (assistant + outbound call)
* **Telephony**: Twilio (paid mode numbers)
* **Obs**: Sentry, Lograge (JSON), Healthcheck endpoint
* **Security**: Rack::Attack, SecureHeaders, verified webhooks, idempotency, PII hygiene

---

## Domain & Schema (final cut)

## Core tables (with key indexes)

* **scenario_templates** *(seeded, versioned)*

  * `slug (uniq), vertical, version:int, prompt_pack:jsonb, active:boolean`
  * Index: `(slug, version)`; partial index on `active`

* **trial_sessions** *(ephemeral “Call-Me” demos)*

  * `code(uniq), vertical, business_name, website, kb:jsonb`
  * `persona_name, voice_id, style, scenario_slug`
  * `vapi_assistant_id, call_limit:int default 3, seconds_cap:int default 120`
  * `prospect_phone, expires_at, status:enum(active|expired|converted|abandoned)`
  * Indexes: `code`, `expires_at`, `status`

* **trial_calls**

  * `trial_session_id (fk), vapi_call_id(uniq), callee_phone`
  * `duration_seconds, recording_url, transcript:jsonb, captured:jsonb, intent`
  * Index: `(trial_session_id, created_at desc)`

* **webhook_events** *(idempotency)*

  * `provider, event_id, raw:jsonb, status, processed_at`
  * Unique index `(provider, event_id)`

* **users** *(Devise passwordless)*

  * `email(uniq)`

* **businesses** *(paid)*

  * `user_id, name, vertical, website`
  * `kb:jsonb, vapi_assistant_id, phone_number`
  * `stripe_customer_id, stripe_subscription_id, subscription_tier, is_unlimited:boolean`
  * Indexes: `user_id`, `stripe_subscription_id`

* **calls** *(paid call logs)*

  * `business_id (fk), vapi_call_id(uniq)`
  * `caller_phone, duration_seconds, recording_url, transcript:jsonb, intent, captured:jsonb`
  * Index: `(business_id, created_at desc)`

* **lead_sources** *(for “real” ingestion later)*

  * `slug(uniq), name, config:jsonb`

* **leads** *(later: speed-to-lead, attribution)*

  * `business_id, lead_source_id, external_id, name, email, phone, channel, status, payload:jsonb`
  * Unique partial index `(lead_source_id, external_id) where external_id is not null`

* **routing_rules** *(later: SLA, quiet hours)*

  * `business_id, trigger, sla_seconds, enabled, criteria:jsonb, actions:jsonb`

> **JSON validation**: use `json_schemer` to validate `prompt_pack` and `captured` payloads at boundaries.

---

## Patterns & Class Design

## Layering

* **Controllers**: thin, resource-oriented, no business logic
* **Services**: pure POROs, one responsibility each (`VapiClient`, `StripeClient`, `OpenAIClient`, `TwilioClient`)
* **Jobs**: orchestration + retries only (`CreateTrialAssistantJob`, `StartTrialCallJob`, `ConvertTrialToBusinessJob`, `TrialReaperJob`)
* **Policies**: Pundit/ActionPolicy for dashboard access
* **ViewComponents** (or Phlex) for reusable UI widgets: CallCard, KPIStat, UpgradeBanner

## State

* TrialSession uses **AASM** or Rails enum for `status` (`active → converted/expired/abandoned`).
* Sidekiq **unique jobs** for create/convert to avoid double work.

## Webhooks (Idempotent-insert pattern)

1. Parse & verify signature (Stripe), or signed secret (Vapi if available).
2. `WebhookEvent.create!` with unique `(provider,event_id)`; if conflict → `200 OK` and return.
3. Enqueue processing job with event primary key.
4. Mark `processed_at` when done.

## Concurrency

* Use Postgres constraints over ifs (e.g., unique `vapi_call_id`)
* Wrap quota decrement or transitions with `SELECT … FOR UPDATE` when needed.
* For trial call caps, assert count in DB **and** enforce in Vapi config (seconds cap).

---

## Devise (passwordless) Setup

* **devise + devise-passwordless**:

  * `User` with `magic_link_token` flow (links expire in 30 minutes).
  * Public trial needs **no login**. Require login only post-checkout and for dashboard.
* Session security:

  * Cookie: `SameSite=Lax`, `Secure`, `HttpOnly`
  * CSRF everywhere except webhooks (`skip_before_action …`)

---

## Styling & Frontend

* **TailwindCSS (tailwindcss-rails)** + **ViewComponent**
* **Stimulus** for behaviors (copy-to-clipboard, tel link w/ commas, timers, toasts)
* **Turbo**:

  * Trial page subscribes via `TrialSessionChannel`
  * Dashboard subscribes via `BusinessChannel`
* Component library options:

  * Rails-native: Tailwind + **DaisyUI** (fast) *or* Tailwind + **ViewComponent lib** of your own atoms.
* **Design tokens**: Tailwind config; light/dark ready
* **Accessibility**: Headings, focus states, aria-labels, transcript text contrast; audio player with keyboard shortcuts

---

## External Clients (Adapters)

```ruby
# app/services/vapi_client.rb
class VapiClient
  BASE = "https://api.vapi.ai"

  def initialize(api_key: ENV.fetch("VAPI_API_KEY"))
    @http = HTTPX.with(
      headers: {"Authorization"=>"Bearer #{api_key}", "Content-Type"=>"application/json"},
      timeout: { connect_timeout: 5, operation_timeout: 10 }  # ⚠️ CRITICAL: Prevent hung jobs
    )
  end

  def create_assistant(name:, prompt_pack:, voice_id:, seconds_cap:, server_url:)
    body = {
      name:, voice: {provider: "elevenlabs", voiceId: voice_id},
      model: prompt_pack.slice(:system, :tools).merge(provider: "openai", model: "gpt-4o-mini", temperature: 0.7),
      firstMessage: prompt_pack[:first_message],
      recordingEnabled: true,
      serverUrl: server_url,
      callTimeLimitSeconds: seconds_cap
    }
    parse @http.post("#{BASE}/assistant", json: body)
  rescue HTTPX::TimeoutError => e
    Rails.logger.error("Vapi timeout: #{e.message}")
    raise VapiTimeoutError, "Voice AI service timeout"
  end

  def outbound_call(assistant_id:, to:, from:)
    parse @http.post("#{BASE}/call/outbound", json: {assistantId: assistant_id, to:, from:})
  rescue HTTPX::TimeoutError => e
    Rails.logger.error("Vapi timeout: #{e.message}")
    raise VapiTimeoutError, "Call initiation timeout"
  end

  private
  def parse(res) = (res.raise_for_status; JSON.parse(res.to_s))
end

# ⚠️ NOTE: Add circuit breaker in T0.14 (see Phase 0 ticket)
```

> Stripe/Twilio adapters similar; set API keys in Rails credentials; raise domain-specific errors.

> ⚠️ **CRITICAL**: All adapters MUST have timeout configuration and circuit breakers before production. See T0.13 and T0.14. Without these, external service outages will cause cascading platform failures.

---

## Jobs & Orchestration

* **GenerateKbJob**: tiny prompt → OpenAI; timeout 5s; fallback to vertical defaults if fail.
* **CreateTrialAssistantJob**: ensure KB present; assemble `prompt_pack` from `scenario_templates + persona/style`; create assistant; set `expires_at = 2.hours`.
* **StartTrialCallJob**: enforce caps; Vapi outbound call; store `prospect_phone`.
* **ConvertTrialToBusinessJob**: clone/upgrade assistant (no caps), create business, buy Twilio number (later), send ready email.
* **TrialReaperJob (cron hourly)**: delete/disable expired assistants; set `status=expired`.

> Use `sidekiq-unique-jobs` for `CreateTrialAssistantJob(trial_session_id)` and `ConvertTrialToBusinessJob(trial_session_id)`.

---

## Controllers & Routes (minimal, REST-y)

```ruby
Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "users/sessions" }

  root "marketing#landing"

  resources :trial_sessions, only: %i[new create show], param: :code do
    post :call, on: :member
  end

  post "/stripe/checkout", to: "stripe_checkout#create"
  namespace :webhooks do
    post :stripe, to: "stripe#create"
    post :vapi,   to: "vapi#create"
  end

  resources :businesses, only: %i[show] do
    member do
      get :dashboard
      post :test_lead # optional later
    end
    resources :calls, only: %i[index show]
  end
end
```

**Security**: webhook controllers verify signatures (Stripe) or shared secrets (Vapi); always 200/fast and hand off to jobs.

---

## Realtime Channels

```ruby
class TrialSessionChannel < ApplicationCable::Channel
  def subscribed
    ts = TrialSession.find_by!(code: params[:code])
    stream_for ts
  end
end

class BusinessChannel < ApplicationCable::Channel
  def subscribed
    authorize! # via Pundit
    stream_for "business_#{params[:id]}"
  end
end
```

* On trial `call.ended`, broadcast `"trial_call_added"` with a rendered partial (CallCard).

---

## Testing Strategy (fast, reliable, high coverage)

> 📖 **Complete pragmatic test strategy in Section 12** - includes critical test examples, anti-patterns to avoid, and phase-by-phase test requirements. This section provides a high-level overview; Section 12 has the detailed solo-dev optimized approach.

**Tooling**

* RSpec + Shoulda Matchers + FactoryBot + Faker
* WebMock + VCR for Vapi/Stripe (happy path + failure)
* Capybara (Cuprite driver) for system tests (Hotwire flows)
* ActionCable test helpers for channel broadcasts
* Sidekiq testing (inline for unit, fake for integration)

**What to test**

* **Models**: validations, JSON schema validation for `prompt_pack`, `captured`
* **Services**: unit tests with stubs (timeouts, retries)
* **Jobs**: idempotency; ensure business created once on webhook replay
* **Controllers**: request specs for trials, webhooks (signature verified), checkout
* **System**:

  * Create trial → assistant ready → start call (mock Vapi) → receive webhook → see call card prepend
  * Checkout success → redirect to dashboard with number (mock Twilio)
* **Security**: rate-limit trial creation by IP; CSRF not required on webhooks

**CRITICAL: Idempotency & Race Condition Testing**

These tests prevent duplicate charges, lost leads, and data corruption. **Required before production.**

```ruby
# spec/jobs/process_vapi_event_job_spec.rb
describe "webhook idempotency" do
  it "handles duplicate webhook events without creating duplicate records" do
    event = create(:webhook_event, event_id: "evt_123", provider: "vapi")
    
    # Process same webhook twice (simulates retry or race condition)
    2.times { ProcessVapiEventJob.perform_now(event.id) }
    
    # Should create exactly 1 Call record (database constraint enforces)
    expect(Call.where(vapi_call_id: "call_123").count).to eq(1)
    expect(event.reload.status).to eq("processed")
  end
  
  it "handles concurrent webhook processing gracefully" do
    event = create(:webhook_event, event_id: "evt_456")
    
    # Simulate concurrent job execution
    threads = 2.times.map do
      Thread.new { ProcessVapiEventJob.perform_now(event.id) rescue nil }
    end
    threads.each(&:join)
    
    # One succeeds, one rescues ActiveRecord::RecordNotUnique
    expect(Call.count).to eq(1)
  end
end

# spec/jobs/convert_trial_to_business_job_spec.rb
describe "conversion idempotency" do
  it "prevents duplicate business creation on webhook retry" do
    trial = create(:trial_session)
    user = trial.user
    
    # Stripe webhook arrives twice (network retry)
    2.times do
      ConvertTrialToBusinessJob.perform_now(
        user_id: user.id,
        trial_session_id: trial.id,
        stripe_subscription_id: "sub_123"
      )
    end
    
    # Only 1 Business created (unique constraints prevent duplicates)
    expect(Business.where(trial_session_id: trial.id).count).to eq(1)
    expect(Business.where(stripe_subscription_id: "sub_123").count).to eq(1)
  end
end

# spec/jobs/start_trial_call_job_spec.rb
describe "call cap enforcement under concurrency" do
  it "respects call limits even with concurrent requests" do
    trial = create(:trial_session, call_limit: 3, calls_used: 2)
    
    # Two concurrent "Call me now" requests (user double-clicks)
    threads = 2.times.map do
      Thread.new { StartTrialCallJob.perform_now(trial.id, "+15551234567") rescue nil }
    end
    threads.each(&:join)
    
    # Only 1 additional call placed (with_lock prevents race)
    expect(trial.reload.calls_used).to eq(3)
  end
end
```

**Circuit Breaker Testing**

```ruby
# spec/services/vapi_client_spec.rb
describe "circuit breaker behavior" do
  it "opens circuit after threshold failures" do
    client = VapiClient.new
    
    # Simulate 5 consecutive failures (threshold)
    5.times do
      expect { client.create_assistant(...) }.to raise_error(Vapi::ServiceUnavailable)
    end
    
    # Circuit should now be open
    expect(Stoplight(:vapi).color).to eq(:red)
    
    # Subsequent calls fail fast without hitting API
    expect { client.create_assistant(...) }.to raise_error(Stoplight::Error::RedLight)
  end
  
  it "closes circuit after cool-off period" do
    # Open circuit
    Stoplight(:vapi).lock(:red)
    
    # Wait for cool-off (30s in config)
    travel 35.seconds
    
    # Should attempt request again (half-open state)
    expect(client.create_assistant(...)).to be_truthy
    expect(Stoplight(:vapi).color).to eq(:green)
  end
end
```

**Contracts**

* Add schema fixtures for Vapi webhook payloads; verify parser stays compatible.

---

## Performance, Scalability & Ops

* **Cold start**: keep a small pool of compiled scenario templates in memory; KB generation is tiny (or cached per vertical).
* **Hot paths**: webhooks and job enqueues—make them O(1) with primary keys and unique constraints.
* **Indexes**:

  * `trial_calls (trial_session_id, created_at desc)`
  * `calls (business_id, created_at desc)`
  * `webhook_events (provider, event_id) unique`
* **Lograge** to JSON; capture `correlation_id` per request and propagate into jobs.
* **Sentry** for Rails + Sidekiq; alert on job retries > 5.
* **Health**: `/up` returns DB/Redis pings for liveness.
* **CI/CD**: GitHub Actions → Fly.io/Render deploy; run DB migrations gated by maintenance window.

---

## Security & Compliance

* Consent checkbox text before trial call; store timestamp + IP (lightweight).
* Quiet hours (8a–9p by default) based on phone area code unless user overrides.
* PII minimization: redact emails/phones from application logs; transcripts purged for non-converted trials after 7 days (scheduled job).
* Stripe customer email matches trial email if captured.
* **CSP** locked down; allow Vapi/Twilio audio domains; HSTS enabled.
* Secret management: `rails credentials:edit` per env; no secrets in `.env` in production.

---

## DX, Quality & Consistency

* **RuboCop + StandardRB** (pick one) with sensible Rails rules
* **Brakeman** in CI
* **Bundler audit** in CI
* **Overcommit** hooks for lint/test on commit
* **Procfile.dev** (web, worker, cable) with `foreman`
* **Ngrok** for local webhook testing; `bin/dev:webhooks` script to tunnel & set webhook URLs

---

## Seed & Versioning

* **[MVP]** Seed **1 template**: `hvac` vertical + `lead_intake` scenario with `scenario_templates(version=1, active=true)`
* **[POST-LAUNCH]** Gym/dental templates: Clone HVAC template when expanding to secondary ICPs (Months 3-6)
* Add `ScenarioTemplate.upsert!` path to ship prompt improvements as `version=2` and select latest `active` per `slug+vertical`.
* Document JSON contract of `prompt_pack` (system, first_message, tools[], examples[]).

---

## Minimal Acceptance Checklist (engineer-ready)

* [ ] Create & validate DB schema exactly as above (including unique indexes).
* [ ] Implement `OpenAIClient.small_kb` (≤ 500 tokens, 5s timeout; fallback to vertical default).
* [ ] Implement `PromptBuilder.for_trial(trial_session, scenario_template)` → returns `{system, first_message, tools}`.
* [ ] Implement `VapiClient#create_assistant / #outbound_call`.
* [ ] Implement `TrialSessionsController (new/create/show)` and `POST /trial/:code/call`.
* [ ] Implement `Webhooks::VapiController` idempotent handler → create `TrialCall`, broadcast.
* [ ] Implement Stripe checkout + webhook → `ConvertTrialToBusinessJob` → paid assistant & (later) Twilio number.
* [ ] Implement `TrialReaperJob` (hourly) to expire assistants.
* [ ] Implement Turbo channels & CallCard component; audio playback + transcript preview.
* [ ] Add Rack::Attack rules (IP throttles for trial creation, call starts).
* [ ] E2E system spec for full trial → webhook → upgrade path (with mocks).
* [ ] Sentry & Lograge configured; healthcheck passes.

---

## Optional niceties (quick wins)

* **State machine** badges in UI (Trial active/expired/converted).
* **“Retry call”** button with countdown until quiet hours resume.
* **One-tap phone link** with commas `tel:+1..., , , CODE` for future shared IVR demos.
* **Flipper** for incremental feature flags (Speed-to-Lead, Email parser).
* **Ahoy/PostHog** for product analytics (TTFA, conversion funnels).

---

This plan keeps the “Call-Me” demo delightful while giving you a maintainable, testable Rails codebase. If you want, I can generate the actual Rails migrations, model skeletons, and the service/job stubs so your engineer can paste them in and run `bin/rails db:migrate` to get the spine booted immediately.

Here’s a clean, engineering-grade phase plan that gets you from nothing → lovable “Call-Me” demo → paid, live accounts. Each phase has goals, build items, and acceptance criteria. Ship after any phase with bolded exit criteria.

---

# Phase 0 — Foundations (Rails spine)

**Goal:** Stable mono repo with auth, jobs, realtime, and observability.

**Build**

* Rails 7.1 / Ruby 3.3, Postgres, Redis, Sidekiq, ActionCable/Hotwire.
* Devise (passwordless magic links); Lograge JSON, Sentry; Rack::Attack; healthcheck `/up`.
* Base gems: pundit/action_policy, view_component (or phlex), httpx/faraday, vcr/webmock, rspec.

**Accept**

* Can boot web + worker locally; background job runs; Sentry receives a test error.
* Auth works for `/dashboard` (trial remains public).
* CI runs lint + tests; deploy once to staging.

---

# Phase 1 — "Call-Me" Personalized Trial (Magic-Link Gated)

**Goal:** Prospect enters email (magic-link auth), customizes agent, picks scenario, enters phone, gets an outbound call.

**Build**

* Schema: `scenario_templates`, `trial_sessions(code,status,expires_at,persona,voice,style,scenario_slug,kb,vapi_assistant_id,call_limit,seconds_cap)`.
* Seed 3 verticals × 3 scenarios (lead_intake, scheduling, info) as JSON prompt packs.
* Services/Jobs: `OpenAIClient.small_kb`, `PromptBuilder.for_trial`, `CreateTrialAssistantJob`, `StartTrialCallJob`, `TrialReaperJob`.
* Pages: `/trial/new` (form), `/trial/:code` (status, “Call me now”).
* Vapi adapter: create assistant (capped) + outbound call.

**Accept**

* From `/trial/new` → assistant ready quickly, “Call me now” triggers a real call to the entered number.
* Caps enforced (≤ N calls, ≤ seconds per call).
* **Exit:** A cold visitor can personalize and receive a working call.

---

# Phase 2 — Trial Webhooks & Mini-Report

**Goal:** After hangup, show what happened (recording, transcript snippet, captured info).

**Build**

* Schema: `trial_calls(trial_session_id,vapi_call_id,recording_url,transcript,captured,intent)`, `webhook_events(provider,event_id)`.
* Webhook: `/webhooks/vapi?trial=1&sessionId=…` (idempotent insert, Sidekiq processing).
* Realtime: `TrialSessionChannel` + Turbo stream prepend of “CallCard”.

**Accept**

* Ending a trial call renders a new card with ▶ recording + transcript preview within the trial page.
* Duplicate webhook events don’t double-insert.

---

# Phase 3 — Payments & Conversion

**Goal:** One-click pay during trial; promote trial config to a real account.

**Build**

* Stripe Checkout endpoint + webhook (verify signature).
* Job: `ConvertTrialToBusinessJob` (clone/upgrade assistant, carry KB/persona/voice, mark trial `converted`).
* Schema: `users`, `businesses(user_id,name,vertical,website,kb,vapi_assistant_id,…)`.

**Accept**

* Clicking Upgrade opens checkout; on completion user lands in a protected dashboard for their new Business with the same agent behavior.
* Idempotent conversion (no duplicate businesses on webhook retry).

---

# Phase 4 — Paid Number & Dashboard Shell

**Goal:** Give paid users “their” number and a live dashboard.

**Build**

* Twilio client (buy/assign number) **or** temporarily use Vapi phone bridge if you want to defer Twilio pool.
* Pages: `/businesses/:id/dashboard` (Stats stub + Recent Calls list).
* Webhook: `/webhooks/vapi` paid path → `calls` table; `BusinessChannel` Turbo updates.

**Accept**

* New paid business has a reachable number; inbound or outbound calls appear live on the dashboard.

---

# Phase 4.5 — Compliance & Guardrails (RUNS IN PARALLEL WITH PHASE 4)

**Goal:** Production-safe defaults; TCPA compliance.

**Build**

* Consent checkbox logging on trial calls; quiet hours (server-side guard); suppression/opt-out for SMS if added.
* Rate limiting: trial creation, call starts, outbound velocity.
* PII hygiene: log redaction; 7-day purge for non-converted trial transcripts.
* DNC list, call permission gating.

**Accept**

* Requests outside quiet hours are blocked or queued with clear UI; purge job removes stale trial data.
* All outbound calls gated by CallPermission (DNC, quiet hours, velocity).

---

# Phase 5 — Scenario Engine Generalization & Hosted Lead Form (optional but powerful)

**Goal:** Reuse the same scenario packs for real callers; enable a no-code "lead intake" form.

**Build**

* Hosted form `/l/:business_id` → `leads` + (optional) `SpeedToLeadJob` placing an outbound agent call to the lead.
* Reuse trial `prompt_pack` in paid assistant (tools: `capture_lead`, `offer_times`), now without time caps.

**Accept**

* Submitting the hosted form triggers an agent call to the submitter; dashboard shows the contact + captured fields.

---

# Phase 6 — Analytics, Emails, Admin

**Goal:** Prove value and keep ops smooth.

**Build**

* KPI tiles (Answer rate, TTFT, Calls/Leads, Booked stubs).
* `DailyReportJob` email with yesterday’s highlights.
* Minimal Admin: view trials, expire/reap, feature flags (Flipper).

**Accept**

* KPIs render from real data; daily email arrives; admin can expire a noisy trial.

---

## 9.5) Analytics & Event Instrumentation (Lightweight Approach)

**Goal:** Measure what matters without over-engineering. Focus on actionable metrics that drive product decisions.

### Core Events to Track (10 Essential Events)

Implement these server-side via `after_commit` hooks or in controllers/jobs:

1. **`trial_session_created`** — User completes trial builder
2. **`trial_call_requested`** — "Call me now" clicked
3. **`trial_call_completed`** — Call ended (track: duration, intent, captured_fields_count, ttfc_ms)
4. **`trial_call_failed`** — Call failed (track: error_reason: vapi_timeout, quiet_hours, cap_exceeded, dnc_blocked, invalid_phone)
5. **`mini_report_viewed`** — User views post-call report
6. **`upgrade_initiated`** — Upgrade button clicked
7. **`upgrade_completed`** — Stripe checkout succeeded
8. **`number_assigned`** — Twilio number purchased
9. **`lead_form_submitted`** — Hosted form POST
10. **`dashboard_viewed`** — Paid user views dashboard

**Additional Compliance/Error Events:**
- **`call_blocked_quiet_hours`** — Outbound blocked by quiet hours
- **`call_blocked_dnc`** — Outbound blocked by DNC list
- **`webhook_processing_failed`** — Webhook job failed (track: provider, error_type)

**Event Properties (Standard):**
- `user_id`, `business_id`, `trial_session_id` (where applicable)
- `created_at` (timestamp)
- Context: `utm_source`, `utm_medium`, `utm_campaign`, `device_type`
- Avoid PII in event properties (use hashes/aggregates)

### Tooling Recommendation

**Phase 1-2:** Use **Ahoy gem** (Rails-native, stores in Postgres)
```ruby
# Gemfile
gem 'ahoy_matey'

# Track events
ahoy.track "trial_call_completed", {
  trial_session_id: trial.id,
  duration_seconds: 87,
  ttfc_ms: 8_500,
  captured_fields_count: 3,
  intent: "lead_intake"
}
```

**Phase 6+:** Consider PostHog/Mixpanel if analytics_daily table proves insufficient. Don't add external tool prematurely.

### North Star Metric Progression

**Months 0-3:** Trial → Paid Conversion Rate (>15%)
- This is your actual North Star until you have 100 paying customers
- Input metrics: TTFC P95, TTFA P95, Trial Completion Rate

**Months 3-6:** Week 1 Activation Rate (>40%)
- % of paid users completing: number assigned + form shared + 2+ dashboard views

**Months 6+:** Weekly Active Businesses (WAB)
- Count of businesses with ≥1 call or lead per week
- Tracks retention and sustained value delivery

### Dashboards to Build (In Order)

**Dashboard 1: Trial Funnel (Phase 2) — PRIORITY**
```
Signups → Trial Created → Call Requested → Call Completed → Mini-Report Viewed → Upgrade
```
- Show TTFC P95, TTFA P95, Webhook→UI latency
- Conversion rates between each step
- Error rate by type (quiet hours, timeouts, cap exceeded)

**Dashboard 2: Paid Health (Phase 4)**
- New conversions this week
- Week 1 activation % (number + form + 2+ dashboard views)
- Calls/leads per business (raw counts)
- D7, D30 retention (simple: % still active)

**Dashboard 3: Compliance & Errors (Phase 4.5)**
- Call block rate by reason (quiet hours, DNC, caps)
- Consent coverage (% trials with consent logged)
- Webhook processing failure rate
- Trial abuse metrics (emails/IP, cost per trial)
- **Circuit breaker status** (Vapi/Stripe/Twilio: open/closed, trips in 24h)

**Critical System Health Indicators:**
- Circuit breaker state (Vapi, Stripe, Twilio): Boolean (green/red)
- Circuit trips (24h window): Count (alert >3)
- Job queue depth: Count (alert >500)
- Webhook backlog: Count of unprocessed events (alert >100)

**Do NOT build:**
- Cohort retention curves (until Month 6+)
- Segment breakdowns (until you have volume)
- Advanced analytics (percentiles, HTE analysis) — overkill for MVP

### Experiment Framework (Simple)

Use Flipper for A/B tests. Keep it lightweight:

**Template:**
```
Experiment: [Name]
Hypothesis: If [change], then [metric] will [direction] by [%] because [reason]
Primary Metric: [One metric only]
Guardrails: TTFC/TTFA/Error rate must not regress
Duration: 1 week
Sample: 50/50 split
Success: p<0.05 or eyeball confidence
```

Run experiments **sequentially** (never >1 trial experiment at once). Use manual SQL analysis or PostHog's built-in A/B tools.

### Implementation Notes

- Store events in `visits` and `events` tables (Ahoy default schema)
- Retention: 90 days for raw events; aggregate into `analytics_daily` indefinitely
- No external analytics tool until Phase 6 (use SQL queries on Ahoy tables)
- PII redaction: never log phones/emails in event properties
- Use `analytics_daily` table (from Phase 6 plan) as source of truth for dashboards

**Cost Control:** Track trial-related costs:
- Vapi spend per trial (target <$0.70)
- Trials per normalized email (alert >3/day)
- Trials per IP (alert >10/hour)

---

## Cross-cutting Implementation Patterns

* **Adapters**: `VapiClient`, `StripeClient`, `OpenAIClient`, `TwilioClient`. Each raises domain errors; all network IO happens in Jobs.
* **Idempotency**: `webhook_events(provider,event_id)` unique; jobs check existence before writes.
* **State**: enums or AASM for `trial_sessions.status`; Sidekiq unique jobs for create/convert.
* **Testing**: RSpec (models/services/jobs/controllers), VCR cassettes for Vapi/Stripe happy/failure paths, Capybara system spec for full trial → webhook → upgrade path, Cable broadcast tests.
* **Styling**: Tailwind + ViewComponent; accessible audio player; Stimulus for toasts/timers.
* **Security**: Devise (passwordless), CSP + HSTS, SecureHeaders, CSRF everywhere except webhooks, Rack::Attack, verified Stripe signatures.

---

## Cut-Lines (you can ship earlier by deferring)

* **Defer Twilio** in Phase 4: use Vapi phone bridge first, add Twilio pool later.
* **Defer Hosted Lead Form/Speed-to-Lead** (Phase 5) if you only need the demo + basic paid.
* **Defer Analytics email** (Phase 6) if dashboard tiles are enough initially.

---

## Simple RACI (single-founder mode)

* **BE Rails**: Controllers, Jobs, Services, Webhooks, Schema.
* **FE Rails**: ViewComponents, Tailwind, Stimulus, Turbo streams.
* **Ops**: Sentry, CI/CD, deploy, envs, webhooks wiring.
* **QA**: System tests + 10 manual E2E runs per phase.

---

If you want, I can turn this into a one-page “Engineering Plan.md” with the exact migrations, routes, and stub class files for Phase 1–3 so your engineer can start coding immediately.


Awesome — here’s **Phase 0: Foundations (Rails spine)** as a detailed, engineer-ready technical plan. It’s broken into scope, architecture choices, code patterns, step-by-step tickets (each with What/Why/AC/Tests), and copy-pasteable snippets. The goal of this phase is to stand up a production-grade Rails skeleton with jobs, realtime, auth, logging, security, CI, and deploy.

---

# Phase 0 — Foundations

**⚠️ ACTUAL IMPLEMENTATION:** Phase 0 completed with Rails 8.1 using SolidQueue instead of Sidekiq. See PHASE-0-IMPLEMENTATION-SUMMARY.md for complete details.

## Objectives (Definition of Done)

**Actually Implemented:**
* Rails **8.1** (Ruby 3.3.6) monolith running locally with **Postgres**, **SolidQueue (database-backed jobs)**, **ActionCable/Hotwire**.
* **Redis only for Rack::Attack** rate limiting (no Redis for jobs).
* **Mission Control Jobs** at `/jobs` for monitoring (not Sidekiq Web UI).
* **Devise (passwordless)** installed and working for authenticated areas (dashboard placeholder).
* **Sentry** for error tracking (Lograge removed due to Rails 8 compatibility).
* **Rack::Attack**, **SecureHeaders**, **healthcheck** endpoint wired.
* **RSpec** test harness (unit, request, system) + **VCR/WebMock** + **parallel test execution**.
* **GitHub Actions** CI pipeline: lint → tests → security scanning.
* **Heroku production** deployed (not staging) with LIVE API keys.
* **4 ViewComponents** (Button, Input, Card, Toast) with theme switching.

**Original Plan (for reference):**
* ~~Rails 7.1~~ → Rails 8.1
* ~~Sidekiq + Redis~~ → SolidQueue (database-backed)
* ~~Lograge~~ → Removed (Rails 8 compatibility)
* ~~8 ViewComponents~~ → 4 ViewComponents (Badge, Dialog, Checkbox, Select deferred)
* ~~Staging deployment~~ → Production deployment (Heroku)

---

## Architecture & Patterns (Phase 0)

**Actual Implementation:**
* **App type**: Rails 8.1 API+views monolith (server-rendered HTML + Hotwire).
* **Storage**: Postgres (UUID primary keys, JSONB where appropriate).
* **Background work**: **SolidQueue** (database-backed, no Redis for jobs).
* **Monitoring**: **Mission Control Jobs** at `/jobs`.
* **Realtime**: Hotwire (Turbo Streams) + ActionCable.
* **Auth**: Devise + devise-passwordless (magic links).
* **Styling**: TailwindCSS v4 + ShadCN-inspired design tokens.
* **HTTP**: `httpx` (fast, HTTP/2) with circuit breakers (Stoplight).
* **Configuration**: Rails Credentials for prod, `.env` for dev/test.
* **Logging/Observability**: Sentry, request IDs, correlation IDs into jobs.
* **Security**: CSP, HSTS, Strict Transport, SameSite cookies, CSRF everywhere except webhooks, IP throttling.
* **Testing**: RSpec, Capybara, WebMock/VCR, Shoulda, FactoryBot, SimpleCov (94%+ coverage), parallel tests. **→ See Section 12 for complete strategy.**

**Key Differences from Original Plan:**
* **SolidQueue** instead of Sidekiq (Rails 8.1 default, simpler ops)
* **Single DATABASE_URL** configuration (SolidQueue/SolidCache use primary DB)
* **Redis only for Rack::Attack** (not for jobs/cache)
* **Production deployment** from day 1 (no staging environment)
* **4 core ViewComponents** (build rest on-demand)

---

## Conventions

* **Namespaces**: `Webhooks::`, `Api::`, `Services::`, `Jobs::`, `Channels::`.
* **PORO services** in `app/services/` with single responsibility (no Rails magic).
* **Jobs**: idempotent, retryable, no business logic (they call services).
* **ViewComponents** (or Phlex) for UI building blocks (cards, stats).
* **Feature flags** later (Phase 4.5/6) via Flipper.

---

## Project Skeleton / Key Files

**Actual Implementation:**
```
app/
  controllers/
    health_controller.rb
    dashboards_controller.rb
  jobs/
    application_job.rb
    test_job.rb
    webhook_processor_job.rb
  services/
    api_client_base.rb
    vapi_client.rb
    twilio_client.rb
    stripe_client.rb
  channels/
    application_cable/
  views/
    dashboards/
  components/           # ViewComponent - 4 primitives built
    primitives/
      button_component.rb
      input_component.rb
      card_component.rb
      toast_component.rb
config/
  initializers/
    stoplight.rb          # Circuit breaker (not sidekiq.rb)
    sentry.rb             # Error tracking only (no lograge.rb)
    rack_attack.rb
    devise.rb
  cable.yml
  queue.yml               # SolidQueue config (not sidekiq.yml)
  storage.yml
Procfile.dev              # web, worker (solid_queue:start), css, js
Procfile                  # web, worker for Heroku
.github/workflows/ci.yml
```

**Key Changes from Original Plan:**
- `config/queue.yml` instead of `config/sidekiq.yml`
- `config/initializers/stoplight.rb` for circuit breakers
- No `config/initializers/lograge.rb` (removed)
- Mission Control Jobs (no Sidekiq Web)
- 4 ViewComponents in `app/components/primitives/`

---

## Tickets (engineering-ready)

Below are concrete tickets. You can paste directly into your tracker. Each includes **What/Why**, **Acceptance Criteria**, **Dev Notes**, and **Tests**.

---

## T0.01 — Bootstrap Repo & Core Gems

**What/Why**
Initialize Rails app with UUIDs, Tailwind, Hotwire, Sidekiq, Devise, Sentry, Lograge, Rack::Attack. Sets technical baseline.

**Acceptance Criteria**

* `bin/dev` boots web (Rails), worker (Sidekiq), and Tailwind watcher.
* Visiting `/up` returns 200 JSON `{status:"ok"}`.
* Running `bundle exec rspec` executes a passing placeholder spec.

**Dev Notes**

```bash
ruby -v        # ensure 3.3.x
rails _7.1.3_ new beakerai --database=postgresql --skip-jbuilder --css=tailwind
cd beakerai

# Core infrastructure
bundle add sidekiq redis lograge rack-attack sentry-ruby sentry-rails httpx

# Resilience & performance
bundle add stoplight          # Circuit breakers (T0.14)

# Auth & UI
bundle add devise devise-passwordless
bundle add view_component     # Component architecture

# Code quality
bundle add standard           # Linting (or rubocop)

# Testing (see Section 12 for complete configuration)
bundle add rspec-rails --group "development,test"
bundle add webmock vcr faker factory_bot_rails shoulda-matchers simplecov --group "test"
bundle add database_cleaner-active_record --group "test"  # For system specs

# Development tools
bundle add bullet --group "development,test"   # N+1 query detection
bundle add letter_opener --group "development" # Email preview
```

Configure test infrastructure per Section 12 (VCR setup, FactoryBot traits, database_cleaner, time helpers).

Enable UUIDs (in a new migration template & application config):

```ruby
# config/application.rb
config.generators do |g|
  g.orm :active_record, primary_key_type: :uuid
  g.helper false
  g.stylesheets false
  g.javascripts false
end
```

Database update:

```yaml
# config/database.yml (dev/test/prod with ENV vars)
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS", 10) %>
  variables:
    statement_timeout: 5000

development:
  <<: *default
  database: beakerai_development

test:
  <<: *default
  database: beakerai_test
```

Generate RSpec:

```bash
rails generate rspec:install
```

Dev Procfile:

```procfile
# Procfile.dev
web: bin/rails server -p 3000
worker: bundle exec sidekiq -C config/sidekiq.yml
css: bin/rails tailwindcss:watch
```

**Tests**

* Add a smoke spec: `spec/requests/health_spec.rb` hitting `/up` returns 200.

---

## T0.02 — Postgres UUIDs & Healthcheck

**What/Why**
Consistent primary keys (uuid) and a universal health endpoint for k8s/Fly.io.

**Acceptance Criteria**

* All new tables default to UUID.
* `GET /up` returns `{status:"ok", db:true, redis:true}` and HTTP 200.

**Dev Notes**

```bash
rails g controller Health up
```

```ruby
# app/controllers/health_controller.rb
class HealthController < ApplicationController
  def up
    db_ok = ActiveRecord::Base.connection.active?
    redis_ok = !!Redis.new(url: ENV.fetch("REDIS_URL", nil)).ping rescue false
    render json: { status: "ok", db: db_ok, redis: redis_ok }
  end
end

# config/routes.rb
get "/up", to: "health#up"
```

**Tests**

* Request spec validates 200 and JSON shape.

---

## T0.03 — Sidekiq + Redis + ActionCable Wiring

**What/Why**
Background jobs & realtime channel backbone.

**Acceptance Criteria**

* Sidekiq dashboard accessible in dev under `/sidekiq` (dev only).
* A dummy job enqueues and runs.

**Dev Notes**

```yaml
# config/sidekiq.yml
:concurrency: 10
:queues:
  - default
  - mailers
```

```ruby
# config/initializers/sidekiq.rb
Sidekiq.configure_server do |c|
  c.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1") }
end
Sidekiq.configure_client do |c|
  c.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1") }
end
```

```ruby
# config/routes.rb
require "sidekiq/web"
authenticate :user, ->(*) { Rails.env.development? } do
  mount Sidekiq::Web => "/sidekiq"
end
```

```bash
rails g job example
```

```ruby
# app/jobs/example_job.rb
class ExampleJob < ApplicationJob
  queue_as :default
  def perform
    Rails.logger.info("ExampleJob ran")
  end
end
```

**Tests**

* Job spec enqueues & performs using `perform_enqueued_jobs`.

---

## T0.04 — Devise (Passwordless Magic Links)

**What/Why**
Secure auth for paid dashboard while keeping trials public. Magic links reduce friction.

**Acceptance Criteria**

* `/users/sign_in` shows email-only login.
* Submitting email sends magic link; following link signs user in.

**Dev Notes**

```bash
rails generate devise:install
rails generate devise User
bundle add devise-passwordless
```

```ruby
# app/models/user.rb
class User < ApplicationRecord
  devise :registerable, :validatable, :rememberable # baseline
  devise :passwordless, authenticatable: false      # magic links only
end
```

Update Devise configs (mailer sender, secret key via credentials). Add minimal layout and a **Dashboard** route protected by `before_action :authenticate_user!`.

**Tests**

* Request spec: unauthenticated access to `/dashboard` redirects to sign in.
* System spec: magic link flow (stub mail with Devise test helpers).

---

## T0.05 — Tailwind + Hotwire + ViewComponents

**What/Why**
Speedy, consistent UI and live updates via Turbo.

**Acceptance Criteria**

* Tailwind working (a badge class renders properly).
* Example Turbo Stream partial broadcast shows on a dummy page.
* ViewComponent renders a Card component.

**Dev Notes**
Tailwind was set by generator; create a simple component:

```bash
rails g component Card title:string
```

Use Turbo on a sample page and show a broadcast from `ExampleJob` (optional).

**Tests**

* ViewComponent test checks render.
* System spec asserts presence of styled element.

---

## T0.06 — Logging & Observability (Lograge + Sentry)

**What/Why**
JSON logs for ingestion; capture exceptions in jobs and controllers.

**Acceptance Criteria**

* Lograge outputs a single JSON line per request (dev/test/prod).
* Sentry receives a test error from both Rails and Sidekiq.

**Dev Notes**

```ruby
# config/environments/production.rb (and development if desired)
config.lograge.enabled = true
config.lograge.formatter = Lograge::Formatters::Json.new
config.lograge.custom_options = lambda do |event|
  { request_id: event.payload[:request_id], user_id: Current.user&.id }
end
```

```ruby
# config/initializers/sentry.rb
Sentry.init do |config|
  config.dsn = Rails.application.credentials.dig(:sentry, :dsn)
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.traces_sample_rate = 0.2
end
```

**Tests**

* Manually hit a route that raises and confirm Sentry logs in console (dev) or via dashboard (staging).

---

## T0.07 — Security: Rack::Attack, SecureHeaders, CSP, CSRF, Cookies

**What/Why**
Default-safe web app posture.

**Acceptance Criteria**

* Basic rate limits active in dev.
* CSP blocks inline scripts unless hashed.
* Cookies: `Secure`, `HttpOnly`, `SameSite=Lax`.

**Dev Notes**

```ruby
# config/initializers/rack_attack.rb
class Rack::Attack
  throttle("req/ip", limit: 100, period: 1.minute) { |req| req.ip }
end
Rack::Attack.enabled = true
```

```ruby
# config/initializers/secure_headers.rb
SecureHeaders::Configuration.default do |config|
  config.hsts = "max-age=63072000; includeSubDomains; preload"
  config.x_content_type_options = "nosniff"
  config.x_frame_options = "SAMEORIGIN"
  config.x_xss_protection = "0"
  config.referrer_policy = "strict-origin-when-cross-origin"
  config.csp = {
    default_src: %w['self'],
    script_src: %w['self'],
    style_src: %w['self' 'unsafe-inline'], # Tailwind in dev
    img_src: %w['self' data:],
    connect_src: %w['self' ws:],          # ActionCable
    media_src: %w['self' data:],
  }
end
```

Ensure CSRF is enabled (default) and skip only in future webhook controllers.

**Tests**

* Request spec: excessive requests → 429 (mock Rack::Attack).
* Security headers present in response.

---

## T0.08 — Standard/Rubocop, Pre-commit Hooks, SimpleCov

**What/Why**
Consistent code quality and coverage visibility.

**Acceptance Criteria**

* `bundle exec standardrb` (or rubocop) passes.
* SimpleCov report generated on test run.

**Dev Notes**

```ruby
# .standard.yml (or .rubocop.yml)
ignore:
  - "db/**/*"
  - "node_modules/**/*"
```

```ruby
# spec/spec_helper.rb
require 'simplecov'
SimpleCov.start 'rails'
```

Optional: `overcommit` to enforce pre-commit hooks.

**Tests**

* CI run fails on style violations.

---

## T0.09 — CI Pipeline (GitHub Actions)

**What/Why**
Automated tests/style on PRs; consistent environment.

**Acceptance Criteria**

* PR triggers lint + test workflow.
* CI uses Postgres & Redis services.

**Dev Notes**

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
        ports: ['5432:5432']
        options: >-
          --health-cmd "pg_isready -U postgres"
      redis:
        image: redis:7
        ports: ['6379:6379']
    env:
      RAILS_ENV: test
      DATABASE_URL: postgres://postgres:postgres@localhost:5432/beakerai_test
      REDIS_URL: redis://localhost:6379/1
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.3'
          bundler-cache: true
      - name: Yarn (if needed)
        run: npm i -g yarn && yarn install --frozen-lockfile || true
      - name: DB setup
        run: bin/rails db:create db:schema:load
      - name: Lint
        run: bundle exec standardrb
      - name: Tests
        run: bundle exec rspec
```

---

## T0.10 — Deploy Pipeline (Staging)

**What/Why**
We need a place to test webhooks and emails before Phase 1.

**Acceptance Criteria**

* App deploys to staging (Fly.io/Render/Heroku) with Postgres/Redis.
* `RAILS_MASTER_KEY` configured; migrations run.
* `/up` returns green in staging.

**Dev Notes (Fly.io example)**

```bash
fly launch  # choose Postgres and Redis add-ons, create apps beakerai-staging and worker
fly secrets set RAILS_MASTER_KEY=...
fly deploy
```

Set process groups in `Procfile`:

```procfile
web: bin/rails server -p ${PORT:-3000}
worker: bundle exec sidekiq -C config/sidekiq.yml
```

---

## T0.11 — Baseline Dashboard Shell (Auth-guarded)

**What/Why**
Confirms Devise works and gives a target route for later phases.

**Acceptance Criteria**

* `/dashboard` requires auth and renders a simple page with user email and basic layout.

**Dev Notes**

```bash
rails g controller Dashboards show
```

```ruby
# app/controllers/dashboards_controller.rb
class DashboardsController < ApplicationController
  before_action :authenticate_user!
  def show; end
end

# config/routes.rb
resource :dashboard, only: :show
```

**Tests**

* Request spec: redirect when unauthenticated; 200 when authenticated.

---

## T0.12 — Developer Experience (bin scripts, local env)

**What/Why**
Reduce onboarding time for new contributors.

**Acceptance Criteria**

* `bin/setup` installs deps, creates DB, runs migrations, seeds dev user.
* README documents local setup, env vars, and common tasks.

**Dev Notes**
`bin/setup` includes:

* `bundle install`
* `rails db:setup`
* `yarn install` (if you use jsbundling)
* create `.env` from `.env.example`

---

## T0.13 — HTTP Client Timeout Configuration

**What/Why**
Configure timeouts for all external service clients to prevent hung jobs.

**Acceptance Criteria**

* Vapi (5s/10s), Twilio (5s/15s), Stripe (5s/15s), OpenAI (10s/30s) configured.
* All adapters raise appropriate errors on timeout.

**Tests**

* Job spec with stubbed timeout; verify raises error.

---

## T0.14 — Circuit Breaker Implementation (MVP)

**What/Why**
Protect platform from cascading failures during external service outages. Without circuit breakers, Vapi/Stripe outages cause cascading job failures, webhook backlogs, and degraded UX.

**Acceptance Criteria**

* Circuit breakers on VapiClient, StripeClient, TwilioClient (open after 50% errors, 60s sleep window).
* Graceful degradation with user-friendly error messages.
* Failed-open state logged to Sentry with context.

**Dev Notes**

Use `stoplight` gem (lightweight, Redis-backed):

```ruby
# Gemfile
gem 'stoplight'

# config/initializers/stoplight.rb
Stoplight::Light.default_data_store = Stoplight::DataStore::Redis.new(
  Redis.new(url: ENV.fetch("REDIS_URL"))
)
Stoplight::Light.default_notifiers = [Stoplight::Notifier::Logger.new(Rails.logger)]

# app/services/vapi_client.rb
class VapiClient
  BASE = "https://api.vapi.ai"
  
  def initialize(api_key: ENV.fetch("VAPI_API_KEY"))
    @http = HTTPX.with(
      headers: {"Authorization"=>"Bearer #{api_key}", "Content-Type"=>"application/json"},
      timeout: { connect_timeout: 5, operation_timeout: 10 }
    )
  end
  
  def create_assistant(name:, prompt_pack:, voice_id:, seconds_cap:, server_url:)
    body = { ... } # existing body
    
    circuit_breaker.run do
      parse @http.post("#{BASE}/assistant", json: body)
    end
  rescue Stoplight::Error::RedLight => e
    # Circuit open - fail fast
    Sentry.capture_message("Vapi circuit open", extra: { method: :create_assistant })
    raise VapiUnavailableError, "Voice AI service temporarily unavailable"
  rescue HTTPX::TimeoutError => e
    Rails.logger.error("Vapi timeout: #{e.message}")
    raise VapiTimeoutError, "Voice AI service timeout"
  end
  
  private
  
  def circuit_breaker
    @circuit_breaker ||= Stoplight(:vapi) do |&block|
      block.call
    end.with_threshold(5)         # Open after 5 failures
       .with_timeout(60)           # Stay open for 60s
       .with_cool_off_time(30)     # Half-open after 30s
       .with_error_handler { |e| e.is_a?(HTTPX::Error) || e.is_a?(VapiTimeoutError) }
  end
  
  def parse(res) = (res.raise_for_status; JSON.parse(res.to_s))
end
```

Apply same pattern to `StripeClient`, `TwilioClient`, `OpenAIClient`.

**Tests**

* Unit test: circuit opens after threshold failures, stays open during timeout.
* Unit test: circuit closes on successful request after cool-off.
* Integration: VapiClient raises `VapiUnavailableError` when circuit open.

---

## T0.14a — Database Connection Pool & Performance Monitoring

**What/Why**
Prevent "connection pool exhausted" errors under load and catch N+1 queries in development before they reach production.

**Acceptance Criteria**

* Connection pool configured with checkout timeout and reaping.
* N+1 query detection active in development (via Bullet gem).
* Partial indexes added for common filtered queries.

**Dev Notes**

```yaml
# config/database.yml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS", 10) %>
  checkout_timeout: 5           # Fail fast if pool exhausted
  reaping_frequency: 10          # Reap dead connections every 10s
  variables:
    statement_timeout: 5000      # Kill queries after 5s

production:
  <<: *default
  database: <%= ENV.fetch("DATABASE_NAME") %>
  url: <%= ENV.fetch("DATABASE_URL") %>
```

```ruby
# Gemfile (development/test)
group :development, :test do
  gem 'bullet'  # N+1 query detection
end

# config/environments/development.rb
config.after_initialize do
  Bullet.enable = true
  Bullet.bullet_logger = true
  Bullet.rails_logger = true
  Bullet.add_footer = true      # Visual indicator in browser
  
  # Raise errors to fail specs
  Bullet.raise = true if Rails.env.test?
end
```

**Partial Indexes (add to migrations):**

```ruby
# db/migrate/..._add_partial_indexes.rb
class AddPartialIndexes < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!
  
  def change
    # Index only active businesses (reduces index size 50%+)
    add_index :businesses, :id, 
              where: "status = 'active'", 
              algorithm: :concurrently,
              name: 'idx_active_businesses'
    
    # Index unconverted trials for reaper job
    add_index :trial_sessions, :expires_at,
              where: "status != 'converted'",
              algorithm: :concurrently,
              name: 'idx_unconverted_trials'
    
    # Index recent calls (dashboard queries)
    add_index :calls, [:business_id, :created_at],
              where: "created_at > NOW() - INTERVAL '30 days'",
              algorithm: :concurrently,
              name: 'idx_recent_calls'
  end
end
```

**Tests**

* Load test: 50 concurrent requests don't exhaust connection pool.
* Spec: N+1 query in dashboard controller fails test (Bullet enabled).
* Query: Partial index used for active businesses query (EXPLAIN ANALYZE).

---

## T0.15 — Design System Foundation

**What/Why**
Establish design tokens, Tailwind configuration, and CSS variables before any feature UI work. Prevents style inconsistency and technical debt accumulation.

**Acceptance Criteria**
- CSS variables defined in `app/assets/stylesheets/tokens.css` for light/dark themes
- Tailwind config (`tailwind.config.js`) maps all semantic tokens
- Mobile-first responsive utilities configured (breakpoints, touch targets)
- Focus ring tokens defined and applied globally
- System font stack configured

**Dev Notes**

```css
/* app/assets/stylesheets/tokens.css */
:root {
  --bg: #ffffff; --fg: #0b0f1a; --muted: #475269;
  --panel: #f6f8fb; --border: #e2e8f0;
  --brand: #0ea5e9; --success: #10b981; --warn: #f59e0b; --danger: #ef4444;
  --radius-sm: 4px; --radius-md: 8px; --radius-lg: 12px;
  --shadow-card: 0 1px 3px rgba(0,0,0,0.1);
}

@media (prefers-color-scheme: dark) {
  :root {
    --bg: #0b0f1a; --fg: #e6e9ef; --muted: #9aa3b2;
    --panel: #111725; --border: #20283a;
  }
}
```

```javascript
// tailwind.config.js additions
module.exports = {
  theme: {
    extend: {
      colors: {
        bg: 'var(--bg)', fg: 'var(--fg)', muted: 'var(--muted)',
        panel: 'var(--panel)', border: 'var(--border)',
        brand: 'var(--brand)', success: 'var(--success)',
        warn: 'var(--warn)', danger: 'var(--danger)'
      },
      spacing: { 2: '0.125rem', 4: '0.25rem', /* ... */ },
      borderRadius: { sm: 'var(--radius-sm)', md: 'var(--radius-md)', lg: 'var(--radius-lg)' }
    }
  }
}
```

**Tests**
- Visual regression: light/dark theme renders correctly
- Token spec: all CSS vars resolve to valid values

**Time estimate:** 1 day

---

## T0.16 — Primitive Component Library (ViewComponents)

**What/Why**
Build 8 reusable UI primitives before feature work. Enforces consistency and prevents inline Tailwind sprawl.

**Acceptance Criteria**
- Components created in `app/components/primitives/`
- Each component has ViewComponent::Preview with 5+ states (default, loading, error, disabled, long-content)
- Preview gallery accessible at `/rails/view_components` in development
- All components keyboard-accessible with visible focus states

**Components to build:**
1. `Button` (variants: primary, secondary, ghost, danger; states: default, loading, disabled)
2. `Input` (with label, error state, helper text)
3. `Checkbox` (with label, error state)
4. `Badge` (variants: default, success, warn, danger)
5. `Card` (with optional header, body, footer slots)
6. `Dialog` (modal with backdrop, close button, keyboard trap)
7. `Toast` (ARIA live region, auto-dismiss, manual close)
8. `Select` (native styled select with error states)

**Dev Notes**

```ruby
# app/components/primitives/button_component.rb
class Primitives::ButtonComponent < ViewComponent::Base
  def initialize(label:, variant: :primary, loading: false, disabled: false, **attrs)
    @label = label
    @variant = variant
    @loading = loading
    @disabled = disabled
    @attrs = attrs
  end

  def call
    tag.button(
      @label,
      class: classes,
      disabled: @disabled || @loading,
      **@attrs
    )
  end

  private

  def classes
    base = "inline-flex items-center px-4 py-2 rounded-md font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2"
    variants = {
      primary: "bg-brand text-white hover:bg-brand/90",
      ghost: "bg-transparent hover:bg-panel",
      danger: "bg-danger text-white hover:bg-danger/90"
    }
    [base, variants[@variant], @loading && "opacity-50 cursor-wait"].compact.join(" ")
  end
end
```

**Tests**
- Component specs: each variant renders correct classes
- Preview specs: all states render without errors
- Accessibility: keyboard nav, focus visible, ARIA attributes

**Time estimate:** 2 days

---

## T0.17 — Trial Flow Wireframes & UI Specifications

**What/Why**
Document detailed UI states, layouts, and user flows for trial experience before implementation. Prevents mid-sprint design churn.

**Acceptance Criteria**
- Low-fidelity wireframes created (Excalidraw, Figma, or Markdown diagrams)
- Mobile (375px) and desktop (1024px+) layouts documented
- All UI states specified: loading, success, error, quiet hours, cap exceeded
- Component inventory mapped to each screen
- Copy/microcopy finalized for consent, CTAs, notifications

**Deliverables:**
1. `/trial/new` (builder) wireframe + state diagram
2. `/trial/:code` (progress → ready → result) wireframe + state transitions
3. Consent checkbox copy finalized
4. Error message templates (timeout, quiet hours, cap exceeded, invalid phone)
5. Mobile navigation patterns

**Format:** Add to `docs/wireframes/trial-flow.md` or embed ASCII diagrams in start.md Phase 1

**Tests**
- No code tests; acceptance is documented wireframes reviewed by team

**Time estimate:** 4-6 hours

---

## Example Snippets (ready to drop)

**ActionCable (Redis adapter)**

```yaml
# config/cable.yml
development:
  adapter: redis
  url: <%= ENV.fetch("REDIS_URL", "redis://localhost:6379/1") %>
production:
  adapter: redis
  url: <%= ENV.fetch("REDIS_URL") %>
```

**CORS (if/when needed)**

```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins /localhost:\d+/, /.*beakerai\.com/
    resource "*", headers: :any, methods: %i[get post options]
  end
end
```

**Request ID → Jobs correlation**

```ruby
# app/controllers/application_controller.rb
around_action :with_request_id

def with_request_id
  RequestStore.store[:request_id] = request.request_id
  yield
ensure
  RequestStore.store[:request_id] = nil
end

# app/jobs/application_job.rb
class ApplicationJob < ActiveJob::Base
  around_perform do |job, block|
    Rails.logger.tagged(request_id: RequestStore.store[:request_id]) { block.call }
  end
end
```

---

## Risks & Mitigations (Phase 0)

* **Redis mismatch**: ensure same REDIS_URL for Sidekiq and Cable in prod.
  *Mitigate*: single `REDIS_URL` env across app.
* **CSP breakage**: Tailwind dev needs `'unsafe-inline'` styles; lock down in prod with hashed styles.
* **Email in dev**: use `letter_opener` or `mailcatcher` to test magic links.
* **Credentials sprawl**: centralize secrets via `rails credentials:edit` per env; forbid `.env` in prod.

---

## Phase 0 Exit Criteria

**✅ COMPLETED - Actual Implementation:**

**Product:**
- [x] `bin/dev` runs 4 processes: web/worker (solid_queue:start)/css/js
- [x] Devise magic link login works and `/dashboard` is protected (placeholder)
- [x] SolidQueue processes jobs (Mission Control UI at `/jobs`)
- [x] Design tokens (CSS vars) configured; light/dark themes working with theme_controller.js
- [x] 4 primitive ViewComponents built with previews (Button, Input, Card, Toast)
- [x] Tailwind config maps all semantic tokens; no raw hex colors in templates
- [x] Focus rings visible on all interactive elements (keyboard nav tested)

**Metrics/SLOs:**
- [x] `/up` health check returns 200 with db status (Redis not required for jobs)
- [x] Smoke test: health check request spec passes
- [x] HTTP timeouts configured for all external clients (Vapi: 5s/10s, Stripe: 5s/15s, Twilio: 5s/15s)

**Operations:**
- [x] Sentry receives errors from web and worker
- [x] Rails default logs visible locally (Lograge removed due to Rails 8 compatibility)
- [x] CI green on PR (lint + tests + security scanning)
- [x] **Production (Heroku) deployed** and reachable at beaker-ai-33941f73a135.herokuapp.com
- [x] Circuit breakers implemented for critical adapters (Vapi + Stripe + Twilio via Stoplight)
- [x] Connection pool configured with checkout timeout
- [x] Bullet gem active in dev/test for N+1 query detection
- [x] Partial indexes added for active businesses, trials, calls
- [x] **SolidQueue configured** with critical/default/low queues in config/queue.yml
- [x] **Mission Control Jobs** UI accessible at `/jobs`
- [x] **Parallel test execution** configured (26% faster, 7s vs 9.38s)
- [x] **SimpleCov coverage** at 94.4% (388/411 lines)

**Risks Mitigated:**
- [x] Vendor outages: Circuit breakers functional for Vapi, Stripe, Twilio
- [x] Performance degradation: Bullet detects N+1 queries, connection pool prevents exhaustion
- [x] Debugging difficulties: Sentry operational
- [x] Job failures: SolidQueue retry logic configured in ApplicationJob
- [x] Security: Rack::Attack rate limiting, webhook signature verification, CSRF protection

**Key Implementation Differences:**
- ✅ SolidQueue instead of Sidekiq (database-backed, no Redis for jobs)
- ✅ Production deployment instead of staging (Heroku with LIVE API keys)
- ✅ 4 ViewComponents instead of 8 (Badge/Dialog/Checkbox/Select deferred)
- ✅ Sentry only (Lograge removed due to Rails 8 compatibility)
- ✅ Single DATABASE_URL (no multi-database setup)
- [ ] Test suite infrastructure complete: RSpec, FactoryBot, VCR, WebMock, Bullet configured (Section 12)

---

If you want, I can generate the actual files (initializers, routes, health controller, Sidekiq config, CI YAML) as a paste-ready bundle for your repo.

Absolutely—here’s the **complete Phase 1** (revised to require magic-link signup before any trial), written so a mid-level Rails engineer can implement it end-to-end.

---

# Phase 1 — “Call-Me” Personalized Trial (Magic-Link Gated)

## Goal (Definition of Done)

A visitor:

1. Enters email → **magic link** → becomes an authenticated `User` (with marketing consent + UTM captured).
2. Lands on **Trial Builder** → chooses vertical, agent persona (Gary/Susan), voice, style, scenario, (business name, website).
3. Clicks **Create demo** → we generate a tiny KB, create a **capped Vapi assistant** (≤120s/call).
4. Enters their phone + consent → clicks **Call me now** → receives an **outbound call within ~10s**.
5. Hard caps: ≤3 calls per trial session, quiet hours enforced (default 8a–9p local).
   (Phase 2 will add webhooks + mini-report; Phase 3 adds checkout and conversion.)

---

## Architecture Overview

* **Rails 7.1 / Ruby 3.3** monolith (from Phase 0)
* **Postgres** (UUID PKs; JSONB for KB & prompts)
* **Redis + Sidekiq** for jobs; **ActionCable** already present but not used yet (Phase 2)
* **Devise + devise-passwordless** for magic-link auth (trial is auth-required)
* **Tailwind + Stimulus** for UI; Turbo polling (ready-check) now, streams later
* **Adapters**: `OpenAIClient`, `VapiClient`, `PromptBuilder`
* **Jobs**: `GenerateKbJob`, `CreateTrialAssistantJob`, `StartTrialCallJob`, `TrialReaperJob`
* **Security**: Rack::Attack throttles; consent & quiet-hours guards; CSRF on non-webhooks

---

## Data Model (migrations)

> All PKs are UUID. Show only new/changed for this phase.

### 1) Users (augment)

```ruby
change_table :users do |t|
  t.boolean  :marketing_opt_in, null: false, default: false
  t.datetime :first_seen_at
  t.datetime :last_seen_at
  t.jsonb    :utm, null: false, default: {} # {source, medium, campaign, content, term, referrer}
end
```

### 2) Email Subscriptions (new)

```ruby
create_table :email_subscriptions, id: :uuid do |t|
  t.uuid     :user_id, null: false, index: true
  t.string   :list,    null: false           # "trial"
  t.boolean  :opt_in,  null: false, default: true
  t.datetime :consented_at, null: false
  t.string   :consent_ip
  t.string   :consent_ua
  t.datetime :unsubscribed_at
  t.timestamps
  t.index [:user_id, :list], unique: true
end
add_foreign_key :email_subscriptions, :users
```

### 3) Scenario Templates (seeded, versioned)

```ruby
create_table :scenario_templates, id: :uuid do |t|
  t.string  :slug,     null: false   # "lead_intake" | "scheduling" | "info"
  t.string  :vertical, null: false   # "gym" | "dental" | "hvac" | "generic"
  t.integer :version,  null: false, default: 1
  t.jsonb   :prompt_pack, null: false # {system, first_message, tools[], examples[]}
  t.boolean :active, null: false, default: true
  t.timestamps
  t.index [:slug, :vertical, :version], unique: true
  t.index [:slug, :vertical], where: "active", name: "idx_active_scenarios"
end
```

### 4) Trial Sessions (owned by user)

```ruby
create_table :trial_sessions, id: :uuid do |t|
  t.uuid   :user_id, null: false, index: true
  t.string :code,    null: false, index: { unique: true } # 6–8 chars
  t.string :vertical, null: false
  t.string :business_name
  t.string :website
  t.jsonb  :kb                         # tiny FAQ/facts
  t.string :persona_name               # "Gary" | "Susan"
  t.string :voice_id                   # "rachel" | "adam" (Vapi/11Labs id)
  t.string :style                      # "friendly" | "professional"
  t.string :scenario_slug, null: false
  t.string :vapi_assistant_id
  t.integer :call_limit,  null: false, default: 3
  t.integer :calls_used,  null: false, default: 0
  t.integer :seconds_cap, null: false, default: 120
  t.string  :prospect_phone
  t.datetime :expires_at, null: false, index: true
  t.string  :status, null: false, default: "active" # active|expired|converted|abandoned
  t.timestamps
end
add_foreign_key :trial_sessions, :users

# ⚠️ CRITICAL: Unique constraints for race condition protection
# The unique index on `code` prevents duplicate trial sessions
# Add unique index on trial_calls.vapi_call_id to prevent duplicate call records
# Database-level uniqueness is the ultimate arbiter for concurrent webhooks
```

---

## Signup Intent (carry preferences through magic link)

A signed/encrypted token (no DB) that stores pre-auth trial choices/UTMs, TTL=2h.

```ruby
# app/lib/signup_intent.rb
class SignupIntent
  KEY = ActiveSupport::KeyGenerator.new(Rails.application.secret_key_base)
                                   .generate_key("signup-intent", 32)
  CRYPTO = ActiveSupport::MessageEncryptor.new(KEY)

  def self.dump(hash) = CRYPTO.encrypt_and_sign(hash.merge("exp" => 2.hours.from_now.to_i))
  def self.load(token)
    data = CRYPTO.decrypt_and_verify(token)
    raise "expired" if data["exp"] && Time.at(data["exp"]) < Time.current
    data.except("exp")
  rescue
    nil
  end
end
```

Fields we include: `{vertical, persona_name, voice_id, style, scenario_slug, business_name, website, utm..., return_to: "/trial/new"}`.

---

## Routes

```ruby
# config/routes.rb
resource  :signup, only: [:new, :create]      # email + marketing consent form
resources :trial_sessions, only: [:new, :create], path: "trial"
get  "/trial/:code",      to: "trial_sessions#show", as: :trial_session
post "/trial/:code/call", to: "trial_sessions#call", as: :call_trial_session
# (webhooks & checkout in later phases)
```

---

## Controllers

### 1) SignupsController (magic-link request page)

* `new`: renders email form, picks up **UTMs** from query and **intent** (optional) to carry over.
* `create`:

  * find_or_create `User` (downcase email)
  * update `marketing_opt_in`, `first_seen_at ||= now`, `last_seen_at = now`, `utm = captured utms`
  * upsert `EmailSubscription(user, "trial")` with consent facts
  * send **magic link** (devise-passwordless) with `redirect_to=/trial/new` and `intent` attached

> Devise: customize the magic-link mailer to include extra params.

```ruby
class SignupsController < ApplicationController
  def new
    @intent_token = params[:intent] # optional, from landing prefill
  end

  def create
    email = params.require(:email).strip.downcase
    user = User.find_or_initialize_by(email:)
    user.marketing_opt_in = ActiveModel::Type::Boolean.new.cast(params[:marketing_opt_in])
    user.first_seen_at ||= Time.current
    user.last_seen_at = Time.current
    user.utm = extract_utms
    user.save!

    EmailSubscription.find_or_create_by!(user:, list: "trial") do |sub|
      sub.opt_in = user.marketing_opt_in
      sub.consented_at = Time.current
      sub.consent_ip = request.remote_ip
      sub.consent_ua = request.user_agent
    end

    intent_token = params[:intent].presence || build_intent_from_prefill
    Devise::Mailer.passwordless_magic_link(user, return_to: "/trial/new", intent: intent_token).deliver_later
    redirect_to root_path, notice: "Check your email for a magic link."
  end

  private

  def extract_utms
    params.permit(:utm_source, :utm_medium, :utm_campaign, :utm_content, :utm_term, :referrer).to_h
  end

  def build_intent_from_prefill
    SignupIntent.dump(params.permit(:vertical, :persona_name, :voice_id, :style, :scenario_slug, :business_name, :website, :utm_source, :utm_medium, :utm_campaign, :utm_content, :utm_term).to_h)
  end
end
```

### 2) Devise: after sign-in redirect

In `ApplicationController` or a `Devise::SessionsController` override:

```ruby
def after_sign_in_path_for(user)
  intent = params[:intent] || request.params[:intent]
  if intent && SignupIntent.load(intent)
    session[:intent_token] = intent
  end
  params[:return_to].presence || "/trial/new"
end
```

### 3) TrialSessionsController

* `new`: requires auth; hydrate form defaults from `session[:intent_token]` if present.
* `create`:

  * create `TrialSession` (owned by `current_user`) with code + 2h TTL
  * enqueue `CreateTrialAssistantJob` (ensures KB)
  * redirect to `show`
* `show`:

  * displays **creating** state; poll `?ready=1` (returns 200 when `vapi_assistant_id` present, 204 otherwise)
* `call`:

  * requires: `consent:true`, `phone`
  * guards: assistant ready, not expired, caps, **quiet hours**
  * enqueue `StartTrialCallJob`; increment `calls_used`; return `202 Accepted`

Skeleton:

```ruby
class TrialSessionsController < ApplicationController
  before_action :authenticate_user!

  def new
    @defaults = intent_defaults
    @verticals = %w[gym dental hvac generic]
    @personas  = %w[Gary Susan]
    @voices    = [{id:"rachel",label:"Rachel"},{id:"adam",label:"Adam"}]
    @styles    = %w[friendly professional]
    @scenarios = %w[lead_intake scheduling info]
  end

  def create
    ts = current_user.trial_sessions.create!(
      code: SecureRandom.alphanumeric(7).upcase,
      vertical: params.require(:vertical),
      business_name: params[:business_name],
      website: params[:website],
      persona_name: params.require(:persona_name),
      voice_id: params.require(:voice_id),
      style: params.require(:style),
      scenario_slug: params.require(:scenario_slug),
      expires_at: 2.hours.from_now
    )
    CreateTrialAssistantJob.perform_later(ts.id)
    redirect_to trial_session_path(ts.code)
  end

  def show
    @ts = current_user.trial_sessions.find_by!(code: params[:code])
    return head(@ts.vapi_assistant_id.present? ? :ok : :no_content) if params[:ready] == "1"
  end

  def call
    ts = current_user.trial_sessions.find_by!(code: params[:code])
    phone   = params.require(:phone)
    consent = ActiveModel::Type::Boolean.new.cast(params[:consent])

    return render status: :unprocessable_entity, plain: "Consent required" unless consent
    return render status: :unprocessable_entity, plain: "Not ready" if ts.vapi_assistant_id.blank?
    return render status: :unprocessable_entity, plain: "Expired"   if ts.expires_at.past?
    return render status: :too_many_requests,  plain: "Call limit reached" if ts.calls_used >= ts.call_limit
    return render status: :forbidden,         plain: "Quiet hours" unless QuietHours.allow?(phone)

    StartTrialCallJob.perform_later(ts.id, phone)
    ts.update!(prospect_phone: phone)  # ⚠️ calls_used incremented by job (atomically)
    head :accepted
  end

  private
  def intent_defaults
    token = session.delete(:intent_token)
    return {} unless token
    SignupIntent.load(token) || {}
  end
end
```

---

## Services

### PromptBuilder

```ruby
class PromptBuilder
  def self.for_trial(ts, template)
    kb = JSON.pretty_generate(ts.kb || {})
    system = template.prompt_pack["system"]
      .gsub("{{persona}}", ts.persona_name)
      .gsub("{{business_name}}", ts.business_name.to_s)
      .gsub("{{vertical}}", ts.vertical)
      .gsub("{{style}}", ts.style)
      .gsub("{{kb}}", kb)

    {
      system: system,
      first_message: template.prompt_pack["first_message"]
        .gsub("{{persona}}", ts.persona_name)
        .gsub("{{business_name}}", ts.business_name.to_s),
      tools: template.prompt_pack["tools"]
    }.deep_symbolize_keys
  end
end
```

### OpenAIClient.small_kb (fast + fallback)

```ruby
class OpenAIClient
  def self.small_kb(vertical:, business:, website: nil)
    # Keep under ~500 tokens, return Hash; fallback if any error/timeout.
    { "hours"=>"Mon–Fri 8–6",
      "pricing"=>"$49–$99/mo",
      "faqs"=>[
        {"q"=>"Do you have day passes?","a"=>"Yes—$15."},
        {"q"=>"Cancel policy?","a"=>"30-day notice; no fees."}
      ] }
  end
end
```

### VapiClient

```ruby
class VapiClient
  BASE = "https://api.vapi.ai"

  def initialize(api_key: ENV.fetch("VAPI_API_KEY"))
    @http = HTTPX.with(headers: {"Authorization"=>"Bearer #{api_key}","Content-Type"=>"application/json"},
                       timeout: {operation_timeout: 20})
  end

  def create_assistant(name:, prompt_pack:, voice_id:, seconds_cap:, server_url:)
    body = {
      name:, voice: {provider:"elevenlabs", voiceId: voice_id},
      model: {provider:"openai", model:"gpt-4o-mini", temperature:0.7,
              systemPrompt: prompt_pack[:system], functions: prompt_pack[:tools]},
      firstMessage: prompt_pack[:first_message],
      recordingEnabled: true,
      serverUrl: server_url,
      callTimeLimitSeconds: seconds_cap
    }
    parse @http.post("#{BASE}/assistant", json: body)
  end

  def outbound_call(assistant_id:, to:, from:)
    parse @http.post("#{BASE}/call/outbound", json: {assistantId: assistant_id, to:, from:})
  end

  private
  def parse(res); res.raise_for_status; JSON.parse(res.to_s); end
end
```

### QuietHours (naive first)

> ⚠️ **PHASE 1 TEMPORARY ONLY**: This uses business timezone. **You MUST upgrade to recipient timezone** (Phase 5) before launching paid features. Using business timezone is a **$500-$1,500 per call TCPA violation**.

```ruby
module QuietHours
  START = 8; END = 21
  
  def self.allow?(e164_phone)
    # ⚠️ TEMPORARY: Uses fixed timezone
    # TODO Phase 5: Replace with PhoneTimezone.lookup(e164_phone)
    now = Time.current.in_time_zone("America/Chicago")
    now.hour >= START && now.hour < END
  end
end
```

**Phase 5 Requirement:** Replace with recipient timezone lookup (see Phase 5 QuietHours implementation).

### EmailNormalizer (trial abuse prevention)

```ruby
module EmailNormalizer
  def self.normalize(email)
    return nil if email.blank?
    
    # Strip whitespace and downcase
    normalized = email.strip.downcase
    
    # Gmail-specific: remove dots and + suffixes
    if normalized.end_with?('@gmail.com')
      local, domain = normalized.split('@')
      local = local.split('+').first  # Remove +suffix
      local = local.gsub('.', '')     # Remove dots
      normalized = "#{local}@#{domain}"
    end
    
    normalized
  end
end
```

---

## Jobs

### GenerateKbJob

```ruby
class GenerateKbJob < ApplicationJob
  queue_as :default
  retry_on StandardError, attempts: 3, wait: :exponentially_longer
  def perform(ts_id)
    ts = TrialSession.find(ts_id)
    return if ts.kb.present?
    ts.update!(kb: OpenAIClient.small_kb(vertical: ts.vertical, business: ts.business_name, website: ts.website))
  end
end
```

### CreateTrialAssistantJob

```ruby
class CreateTrialAssistantJob < ApplicationJob
  queue_as :default
  retry_on StandardError, attempts: 3, wait: :exponentially_longer
  def perform(ts_id)
    ts = TrialSession.find(ts_id)
    GenerateKbJob.perform_now(ts.id) unless ts.kb.present?
    tmpl = ScenarioTemplate.active.where(vertical: ts.vertical, slug: ts.scenario_slug).order(version: :desc).first!
    pack = PromptBuilder.for_trial(ts, tmpl)

    # Phase 2 will consume webhooks at this serverUrl
    server_url = Rails.application.routes.url_helpers.webhooks_vapi_url(
      host: ENV.fetch("APP_URL"), sessionId: ts.id, trial: 1
    )

    assistant = VapiClient.new.create_assistant(
      name: "#{ts.persona_name} (Demo)",
      prompt_pack: pack,
      voice_id: ts.voice_id,
      seconds_cap: ts.seconds_cap,
      server_url: server_url
    )
    ts.update!(vapi_assistant_id: assistant["id"])
  end
end
```

### StartTrialCallJob

```ruby
class StartTrialCallJob < ApplicationJob
  queue_as :default
  
  def perform(ts_id, phone)
    ts = TrialSession.find(ts_id)
    
    # ⚠️ CRITICAL: Use with_lock to prevent race conditions
    ts.with_lock do
      raise "not ready" if ts.vapi_assistant_id.blank?
      raise "expired"   if ts.expires_at.past?
      raise "limit"     if ts.calls_used >= ts.call_limit
      raise "quiet"     unless QuietHours.allow?(phone)

      VapiClient.new.outbound_call(
        assistant_id: ts.vapi_assistant_id,
        to: phone,
        from: ENV.fetch("DEMO_OUTBOUND_NUMBER")
      )
      
      # Increment within lock to prevent double-calls
      ts.increment!(:calls_used)
    end
  rescue VapiTimeoutError => e
    # Circuit breaker or timeout - surface to user
    Sentry.capture_exception(e)
    raise
  end
end
```

### TrialReaperJob (hourly)

```ruby
class TrialReaperJob < ApplicationJob
  queue_as :default
  def perform
    TrialSession.where("expires_at < ? AND status='active'", Time.current).find_each do |ts|
      begin VapiClient.new.delete_assistant(ts.vapi_assistant_id) rescue nil end
      ts.update!(status: "expired")
    end
  end
end
```

> ⚠️ **CONCURRENCY CRITICAL**: All jobs that modify trial state MUST use `with_lock` or rely on database unique constraints. Race conditions from concurrent webhook processing can create duplicate calls/charges. See updated StartTrialCallJob above.

---

## Views / UX (Detailed Specifications)

### Mobile-First Requirements
- All screens must work at 375px width (iPhone SE)
- Touch targets minimum 44px height × 44px width
- Bottom navigation for mobile primary actions
- No horizontal scroll on any breakpoint
- Grid layouts: 1-col mobile → 2-col tablet → 3-col desktop

### Screen 1: `/signup` (Magic Link Entry)

**Layout (Mobile):**
```
┌─────────────────────────────────┐
│ [Logo]  Beaker AI               │
│                                 │
│ Try your AI phone agent         │
│ Get a live demo in 60 seconds   │
│                                 │
│ [Email Input - Large]           │
│ ☐ Email me tips & recordings    │
│                                 │
│ [Get Started →] (Primary CTA)   │
│                                 │
│ Hidden: UTM params              │
└─────────────────────────────────┘
```

**States:**
- Default: Empty form, button enabled
- Submitting: Button shows loading spinner, disabled
- Success: Toast "Check your email for magic link"
- Error: Inline error under email input, red border

**Components:** `Input`, `Checkbox`, `Button` (loading state), `Toast`

**Copy:**
- CTA: "Get Started" (not "Submit")
- Consent: "Email me call recordings and tips" (clear value prop)
- Error: "Please enter a valid email address"

---

### Screen 2: `/trial/new` (Trial Builder)

**Layout (Desktop 2-column, Mobile stacked):**
```
┌──────────────────────┬──────────────────────┐
│ Configure Your Agent │ What You'll Get      │
│                      │                      │
│ [Business Type ▾]    │ ✓ Personalized voice │
│ [Persona: Gary ▾]    │ ✓ Custom script      │
│ [Voice: Rachel ▾]    │ ✓ 3 free test calls  │
│ [Style: Friendly ▾]  │ ✓ Call recording     │
│                      │                      │
│ [Create My Agent →]  │ "Takes ~20 seconds"  │
└──────────────────────┴──────────────────────┘
```

**Mobile:** Stack vertically, benefits collapse into expandable section

**States:**
- Default: Form with defaults pre-filled from intent token
- Creating: Button disabled, form replaced with progress indicator
- Error: Toast "Something went wrong, please try again"

**Components:** `Select`, `Button`, `Card` (benefits panel)

---

### Screen 3: `/trial/:code` (Progress → Ready → Call → Result)

**State 1: Creating Assistant (20s)**
```
┌─────────────────────────────────┐
│ Creating your agent...          │
│                                 │
│ [████████░░] 80%                │
│                                 │
│ ✓ Analyzed your business        │
│ ✓ Generated voice script        │
│ ⏳ Starting agent...            │
│                                 │
│ (Polls ?ready=1 every 2s)       │
└─────────────────────────────────┘
```

**State 2: Ready to Call**
```
┌─────────────────────────────────┐
│ [Limits Badge: 2/3 calls • 120s]│
│                                 │
│ ✅ Your agent is ready!         │
│                                 │
│ [Phone Number Input]            │
│ ☑ I consent to receive call     │
│     (Required by law)            │
│                                 │
│  [📞 Call Me Now] Large CTA     │
│                                 │
│ "Your agent will call in ~10s"  │
└─────────────────────────────────┘
```

**State 3: Calling (Optimistic UI)**
```
┌─────────────────────────────────┐
│ [Limits: 1/3 calls • 120s left] │
│                                 │
│ 📞 Calling you now...           │
│ [Animated phone icon]           │
│                                 │
│ (Shows immediately after click, │
│  before backend confirms)       │
└─────────────────────────────────┘
```

**State 4: Call Result (Turbo Stream Prepends)**
```
┌─────────────────────────────────┐
│ [NEW] Call #1 - 2m ago          │
│ ├─ Duration: 1:34               │
│ ├─ Intent: [Lead Intake] badge  │
│ ├─ Captured: Name, Phone        │
│ ├─ [▶ Play Recording]           │
│ └─ [View Transcript ↓]          │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ Ready to go live?           │ │
│ │ [Upgrade Now →]             │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

**State 5: Quiet Hours Block**
```
┌─────────────────────────────────┐
│ ⏰ Calls paused                 │
│                                 │
│ Outbound calling is restricted  │
│ outside 8AM-9PM (lead's time).  │
│                                 │
│ Your request will resume at:    │
│ 8:00 AM PST (in 6 hours)        │
│                                 │
│ [Why?] → Compliance explanation │
└─────────────────────────────────┘
```

**State 6: Cap Exceeded**
```
┌─────────────────────────────────┐
│ [Limits: 3/3 calls used]        │
│                                 │
│ Trial limit reached             │
│                                 │
│ You've used all 3 trial calls.  │
│ Upgrade to continue testing.    │
│                                 │
│ [Upgrade Now →] Primary CTA     │
└─────────────────────────────────┘
```

**State 7: Error (Timeout/Failure)**
```
┌─────────────────────────────────┐
│ ❌ Call failed                  │
│                                 │
│ We couldn't connect right now.  │
│ This doesn't count against your │
│ trial limit.                    │
│                                 │
│ [Try Again] [Contact Support]   │
└─────────────────────────────────┘
```

**Components Used:**
- `Badge` (limits pill, intent chip)
- `Button` (primary CTA, ghost secondary)
- `Input` (phone with E.164 hint)
- `Checkbox` (consent)
- `Card` (call result cards)
- `Toast` (error notifications)
- Custom: `AudioPlayer`, `Transcript` (collapsible)

---

### CallCard Component Specification

```ruby
# Voice::CallCard
Props:
- duration_seconds (Integer)
- intent (String: "lead_intake", "scheduling", "info")
- captured_fields (Hash: {name: "John", phone: "+1..."})
- recording_url (String, optional)
- transcript_preview (String, first 3-5 lines)
- created_at (DateTime)

Slots:
- actions (optional, for admin "Delete" etc.)

States:
- collapsed (default): Show summary only
- expanded: Show full transcript (collapsible)
- playing: Audio player active state
```

---

### Consent Copy (Finalized)

**Trial call consent:**
"I agree to receive an automated test call to the number provided. This call may be recorded."

**Hosted lead form consent:**
"I agree to receive an automated call to discuss my inquiry. Calls may be recorded. Message & data rates may apply."

**Recording notice (in agent first message):**
"This call may be recorded for quality and training purposes."

---

### Error Messages (Finalized)

| Scenario | Message | Action |
|---|---|---|
| Vapi timeout | "We couldn't create your agent right now. Please try again." | [Retry] button |
| Invalid phone | "Please enter a valid phone number (e.g., +1 555-555-1234)" | Inline, red border |
| No consent | "You must consent to receive the call to continue." | Focus checkbox |
| Quiet hours | "Calls paused until 8:00 AM PST. [Why?]" | Show queue state |
| Cap exceeded | "Trial limit reached (3/3 calls). Upgrade to continue." | [Upgrade] CTA |
| Call failed | "Call failed. This doesn't count against your limit. [Try Again]" | Retry enabled |

---

---

## Rate Limiting & Consent

* Rack::Attack throttles:

  * `/signup` per IP (e.g., 10/min)
  * `/trial` create per IP (e.g., 5/10min)
  * `/trial/:code/call` per IP (e.g., 5/10min)
* Consent stored implicitly in **EmailSubscription** (marketing) and explicitly via `consent` param on call (server rejects if false). We’re not storing phone-call consent record (add later if needed).

---

## Tickets (What/Why/AC/Tests)

> Copy into your tracker. Each has Acceptance Criteria (AC) & Tests.

### P1-01: Migrations & Models (Users++, EmailSubscriptions, ScenarioTemplates, TrialSessions)

* **Why:** Persist users w/ marketing + utm, subscriptions, templates, trials.
* **AC:** Migrations run; constraints & indexes present; enums on `trial_sessions.status`.
* **Tests:** Model validations; default values; `ScenarioTemplate.fetch` returns active latest.

### P1-02: Seeds — Scenario Templates (HVAC lead_intake only) **[MVP]**

* **Why:** Deterministic prompt packs; no OpenAI dependency for structure. Focus on single ICP validation.
* **AC:** `rails db:seed` creates 1 active template: `lead_intake` for `hvac` vertical (version 1, active: true).
* **Tests:** Seed spec asserts presence & shape.
* **Note:** Gym/dental templates **[POST-LAUNCH]** — Clone HVAC template when expanding to secondary ICPs.

### P1-03: Signup (email + marketing consent) & Magic-Link flow

* **Why:** Identify trialers; drip capability; legal opt-in.
* **AC:** `/signup` renders; submit captures consent/IP/UA/UTM; sends magic link w/ `return_to=/trial/new` + `intent`.
* **Tests:** Request spec: creates/updates user; inserts subscription; sends mail.

### P1-04: Devise after_sign_in redirect w/ intent token

* **Why:** Land user in trial builder with prefilled selections.
* **AC:** After click, user is authenticated and redirected to `/trial/new`; defaults populated from `intent`.
* **Tests:** Request/system: intent round-trip preserved.

### P1-05: OpenAIClient.small_kb & PromptBuilder.for_trial

* **Why:** Generate compact KB; assemble final system prompt.
* **AC:** Returns <500 token KB Hash; builder replaces placeholders & returns `{:system,:first_message,:tools}`.
* **Tests:** Unit tests for both; error fallback case for OpenAI.

### P1-06: VapiClient#create_assistant / #outbound_call

* **Why:** Clean adapter boundary; raise on non-200.
* **AC:** Happy path returns parsed JSON; 500/timeout raises.
* **Tests:** WebMock/VCR: 200 & 500; timeouts.

### P1-07: TrialSessionsController (new/create/show w/ ready-polling)

* **Why:** Auth-gated builder & readiness UI.
* **AC:** Auth required; `POST /trial` → redirects to `/trial/:code`; `?ready=1` returns 200 when ready, else 204.
* **Tests:** Request & system tests.

### P1-08: CreateTrialAssistantJob (+ GenerateKbJob)

* **Why:** Async assistant build w/ KB fallback & retries.
* **AC:** Sets `vapi_assistant_id`; retries on transient errors.
* **Tests:** Job specs w/ stubs; idempotent behavior.

### P1-09: StartTrialCallJob & Controller `call` endpoint

* **Why:** Place outbound call with consent, caps, quiet hours.
* **AC:** `202 Accepted` on success; returns appropriate 4xx otherwise; increments `calls_used`.
* **Tests:** Request spec for each guard; job spec calls adapter.

### P1-10: TrialReaperJob (hourly)

* **Why:** Cleanup expired trials; cost control.
* **AC:** Trials past TTL become `expired`; assistant delete best-effort.
* **Tests:** Time-travel spec; ignore delete errors.

### P1-11: Rack::Attack throttles (signup/trial/call)

* **Why:** Abuse prevention on public-ish flows.
* **AC:** Requests above thresholds → 429.
* **Tests:** Request specs simulating bursts.

### P1-12a: Signup & Builder UI (Mobile-First)

**What/Why**
Implement signup and trial builder screens with mobile-first responsive layouts, ensuring fast perceived performance and clear CTAs.

**Acceptance Criteria**
- `/signup` renders with email input, consent checkbox, primary CTA
- Mobile: single column, touch-friendly (44px min)
- Desktop: centered form, max-width 480px
- Button shows loading state on submit (Stimulus controller)
- Success shows toast notification
- Error shows inline validation (red border, helper text)
- `/trial/new` renders with 4 select inputs, defaults pre-filled from intent token
- Desktop: 2-column layout (form | benefits)
- Mobile: stacked, benefits collapsible
- "Create My Agent" button triggers page transition with optimistic loading state

**Components Used**
- `Primitives::Input`, `Primitives::Checkbox`, `Primitives::Button`, `Primitives::Select`, `Primitives::Card`, `Primitives::Toast`

**Stimulus Controllers**
- `form-submit` (handles loading states, client-side validation)
- `toast` (auto-dismiss after 5s, manual close)

**Tests**
- System spec: signup flow (fill form → submit → see toast)
- System spec: builder flow (select options → submit → redirect)
- Request spec: mobile viewport (375px) renders without horizontal scroll
- Accessibility: keyboard tab order, focus visible

**Time estimate:** 2 days

---

### P1-12b: Trial Progress & Ready States

**What/Why**
Implement assistant creation progress indicator and ready state UI with clear affordances for calling.

**Acceptance Criteria**
- `/trial/:code` shows progress bar when `vapi_assistant_id` is null
- Progress updates via polling `?ready=1` every 2s (Stimulus controller)
- Steps shown: "Analyzed business", "Generated script", "Starting agent"
- When ready, shows phone input, consent checkbox, "Call Me Now" CTA
- Limits badge visible: "X/3 calls • Ys max" (updates live)
- Phone input validates E.164 format client-side (hint text shown)
- Consent checkbox required (button disabled until checked)
- "Call Me Now" click shows optimistic "Calling..." state immediately
- Backend 202 response keeps optimistic state; error rolls back

**Components Used**
- `Primitives::Input` (phone), `Primitives::Checkbox`, `Primitives::Button`, `Primitives::Badge`
- Custom: `ProgressIndicator` (simple div with percentage)

**Stimulus Controllers**
- `ready-poller` (polls ?ready=1, transitions to ready state)
- `call-initiator` (optimistic UI, handles 202/4xx responses)
- `phone-validator` (E.164 format hint)

**Tests**
- System spec: poll until ready, then enable call button
- Request spec: ready state includes all form elements
- JS spec: optimistic UI shows immediately, rolls back on error

**Time estimate:** 2 days

---

### P1-12c: Call Result Cards & Turbo Updates

**What/Why**
Display call mini-reports with audio player, transcript preview, and captured fields. Use Turbo Streams for real-time prepends.

**Acceptance Criteria**
- Webhook `call.ended` triggers Turbo Stream broadcast
- New `Voice::CallCard` component prepends to `#trial_calls` target
- Card shows: timestamp, duration, intent badge, captured fields chips
- Audio player with play/pause, seek controls (keyboard accessible)
- Transcript collapsible (default: first 5 lines, "[Read more ↓]")
- Expanded transcript virtualizes long content (>50 lines)
- "Upgrade" CTA shown prominently after first successful call
- No layout shift when card prepends (reserved height or skeleton)

**Components Used**
- `Voice::CallCard` (new ViewComponent)
- `Voice::AudioPlayer` (new, with keyboard controls)
- `Voice::Transcript` (collapsible, virtualized)
- `Primitives::Badge` (intent chip)

**Stimulus Controllers**
- `audio-player` (keyboard: Space=play/pause, ←/→=seek, ↑/↓=volume)
- `disclosure` (expand/collapse transcript)

**Tests**
- System spec: webhook triggers Turbo prepend, card appears
- Component spec: CallCard renders all data correctly
- Accessibility: audio player operable via keyboard
- Performance: no CLS when card prepends (measure with Lighthouse)

**Time estimate:** 2-3 days

---

### P1-12d: Error & Edge States UI

**What/Why**
Handle quiet hours, cap exceeded, timeouts, and validation errors with clear, actionable UI.

**Acceptance Criteria**
- Quiet hours: replace "Call Me Now" with notice banner + queue time
- "Why?" link opens modal explaining TCPA compliance
- Cap exceeded: disable call button, show "Upgrade" CTA
- Timeout: show error toast, enable retry (doesn't decrement cap)
- Invalid phone: inline error, red border, helper text
- No consent: disable button until checked

**Components Used**
- `Primitives::Dialog` (compliance modal)
- `Primitives::Toast` (error notifications)
- Custom: `QuietHoursNotice`, `CapExceededBanner`

**Stimulus Controllers**
- `modal` (open/close, keyboard trap, focus management)
- `timezone-hint` (shows recipient's local time based on area code)

**Copy (finalized)**
- Quiet hours: "Outbound calls paused until 8:00 AM PST (in 6 hours). [Why?]"
- Cap exceeded: "Trial limit reached (3/3 calls). Upgrade to continue."
- Timeout: "We couldn't connect right now. Please try again."

**Tests**
- System spec: quiet hours shows banner instead of button
- System spec: cap exceeded disables button, shows upgrade
- Request spec: each error state returns correct 4xx + message
- Accessibility: modal keyboard trap, focus returns to trigger on close

**Time estimate:** 1.5 days

---

### P1-13: Trial Abuse Prevention

* **What/Why:** Prevent unlimited trial creation via email rotation (Gmail + trick).
* **AC:** Email normalization (strip +, dots in Gmail); rate limit trial creation by IP; hCaptcha optional.
* **Tests:** Request spec: normalized emails dedupe; IP throttle returns 429.

---

## Testing Matrix

* **Models:** Users (marketing/utm), EmailSubscription, ScenarioTemplate, TrialSession
* **Services:** OpenAIClient (stub/fallback), PromptBuilder, VapiClient (VCR/WebMock)
* **Jobs:** GenerateKbJob, CreateTrialAssistantJob, StartTrialCallJob, TrialReaperJob
* **Controllers (requests):** Signups, TrialSessions (create/show/call)
* **System:** End-to-end: signup → auth → builder → create trial → show ready → call (with stubs)
* **Security:** Rack::Attack (429), CSRF present on non-webhooks

Coverage target for Phase 1 code: **≥85%**.

---

## Non-Functional Targets

* **TTFA (first agent ready):** ≤ 20s (fallback KB instantly if OpenAI slow)
* **TTFC (first call after “Call me now”):** ≤ 10s
* **Reliability:** job retries exponential; idempotent trial creation w/ unique `code`
* **Compliance:** opt-in captured; consent required for calls; quiet hours enforced

---

## Phase 1 Exit Criteria

**Product:**
- [ ] Magic-link signup required; UTM + consent stored; "trial" subscription created
- [ ] Authenticated user can create a trial; assistant becomes ready (polling works)
- [ ] User can request an outbound call; call placed; caps & quiet hours enforced; consent required
- [ ] All screens work on mobile (375px width tested); no horizontal scroll at any breakpoint
- [ ] Touch targets ≥44px for all buttons/inputs
- [ ] Bottom navigation present on mobile trial flow
- [ ] ViewComponent previews exist for all UI components with 5+ states
- [ ] Error states render clear, actionable messages
- [ ] Consent copy finalized and legally reviewed

**Metrics/SLOs:**
- [ ] Pre-launch validation completed (Section 10.6): 5+ positive responses, 1+ manual demo
- [ ] TTFA ≤20s P95 (assistant ready from creation)
- [ ] TTFC ≤10s P95 (call initiated after button click)
- [ ] Trial call success rate >85%
- [ ] No layout shift when Turbo prepends call cards (CLS <0.02 measured)

**Operations:**
- [ ] Trial abuse prevention active (email normalization, IP throttles)
- [ ] Cost/trial P90 <$0.70 (monitored via Dashboard 3)
- [ ] Throttles active; friendly errors render; jobs retry transient failures
- [ ] CI green; staging deploy matches behavior
- [ ] Keyboard navigation works for entire trial flow (tab order correct)
- [ ] Focus rings visible on all interactive elements
- [ ] Audio player operable via keyboard (Space, arrows tested)

**Risks Mitigated:**
- [ ] ICP validation: Strong signal from pre-launch (Section 10.6 exit criteria met)
- [ ] Trial abuse: Auto-blocks working, cost monitoring active
- [ ] Race conditions: Database unique constraints prevent duplicate trial sessions
- [ ] Vendor outages: Circuit breakers handle timeouts gracefully
- [ ] **Tests (15 total, <30s):** Magic-link auth, trial limits, trial abuse, race conditions, request specs for trial creation/call trigger (see Section 12)

---

If you’d like, I can also hand you **ready-to-paste seeds** for 9 scenario templates and ERB/Stimulus for `/signup`, `/trial/new`, and `/trial/:code` so you can see the UI states immediately.

Awesome — here’s **Phase 2: Trial Webhooks & Mini-Report** as a complete, engineer-ready plan. This assumes Phase 1 is shipped with magic-link signup and trial calls working.

---

# Phase 2 — Trial Webhooks & Mini-Report

## Goal (Definition of Done)

* When a trial call **ends**, the user’s **trial page updates in real time** (Turbo) with a **mini-report**:

  * ▶ **Recording**, transcript snippet, **captured fields** (name/goal/time/email), **intent** chip, duration.
* **Idempotent** webhook handling (no dup rows on retries).
* **Security**: verified or secret-keyed webhooks; respond fast; process in background.
* **Retention**: non-converted trial transcripts auto-purged after 7 days.
* **Counters**: calls used/limit visually accurate and updated live.

---

## Architecture Changes

* Add **trial_calls** table (+ indexes).
* Add **webhook_events** table for idempotency.
* New controller **Webhooks::VapiController** (fast 200, enqueue).
* New job **ProcessVapiEventJob** (parse, persist, broadcast).
* New small services:

  * **VapiPayload** (normalizes payload, safe digging)
  * **LeadExtractor** (from functionCalls/transcript)
  * **IntentClassifier** (function-aware, transcript fallback)
  * **TranscriptSanitizer** (PII redaction for logs/preview)
* Use **TrialSessionChannel** ActionCable stream on trial page.
* Add **PurgeOldTrialsJob** (7-day retention for non-converted).

---

## Data Model (migrations)

### 1) `webhook_events` (idempotency)

```ruby
create_table :webhook_events, id: :uuid do |t|
  t.string   :provider,  null: false  # "vapi"
  t.string   :event_id,  null: false
  t.jsonb    :raw,       null: false, default: {}
  t.string   :status,    null: false, default: "received" # received|processed|failed
  t.datetime :processed_at
  t.timestamps
  t.index [:provider, :event_id], unique: true
end
```

### 2) `trial_calls`

```ruby
create_table :trial_calls, id: :uuid do |t|
  t.uuid    :trial_session_id, null: false, index: true
  t.string  :vapi_call_id,     null: false, index: { unique: true }
  t.string  :callee_phone
  t.integer :duration_seconds
  t.string  :recording_url
  t.jsonb   :transcript,       null: false, default: {} # array or text chunks
  t.jsonb   :captured,         null: false, default: {} # { name, phone, email, goal, time }
  t.string  :scenario_slug
  t.string  :intent            # "lead_intake"|"scheduling"|"info"|"other"
  t.timestamps
end
add_foreign_key :trial_calls, :trial_sessions
```

*(Optional) Add `retained_until:datetime` if you want explicit retention timestamps.*

---

## Routes

```ruby
# config/routes.rb
namespace :webhooks do
  post :vapi, to: "vapi#create"
end

# Turbo channel already present or add:
# mount ActionCable at /cable (default)
```

---

## Security

* **Signature verification**: if Vapi provides HMAC, verify with `VAPI_WEBHOOK_SECRET`. If not available, require a random **query secret** on the serverUrl you set in Phase 1: `serverUrl: .../webhooks/vapi?sessionId=..&trial=1&token=<random>`.
* Enforce **HTTPS**; skip CSRF only for this controller.
* Rate-limit webhook route with Rack::Attack (gentle threshold to avoid needless 429s).

---

## Controller: `Webhooks::VapiController`

* Parse JSON; compute a **stable event_id**:

  * Prefer payload `id` or `"#{type}-#{call.id}-#{delivered_at}"`.
* Upsert `WebhookEvent(provider:"vapi", event_id)`; if exists, return **200 OK** (idempotent).
* Enqueue `ProcessVapiEventJob` with `webhook_event.id`.
* Return **200 OK** immediately.

```ruby
class Webhooks::VapiController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :verify_signature!

  def create
    payload = JSON.parse(request.raw_post)
    event_id = payload["id"] || [payload["type"], payload.dig("call","id"), payload["deliveredAt"]].compact.join(":")

    wh = WebhookEvent.create!(
      provider: "vapi",
      event_id: event_id,
      raw: payload,
      status: "received"
    )
    ProcessVapiEventJob.perform_later(wh.id, params.permit(:trial, :sessionId).to_h)

    head :ok
  rescue ActiveRecord::RecordNotUnique
    head :ok
  rescue JSON::ParserError
    head :bad_request
  end

  private

  def verify_signature!
    return if Rails.env.development? # relax in dev
    token = params[:token].presence
    secret = ENV["VAPI_WEBHOOK_SECRET"]
    head :unauthorized unless ActiveSupport::SecurityUtils.secure_compare(token.to_s, secret.to_s)
  end
end
```

> ⚠️ **IDEMPOTENCY + CONCURRENCY**: The unique constraint on `webhook_events(provider, event_id)` prevents duplicate processing, but NOT concurrent processing. Jobs must handle `ActiveRecord::RecordNotUnique` gracefully. See ProcessVapiEventJob for pattern.

---

## Job: `ProcessVapiEventJob`

* Load event; short-circuit if already processed.
* Only handle `type == "call.ended"`. Ignore others for now.
* Resolve **trial session**:

  * From job args `sessionId` (we put it on the `serverUrl` in Phase 1).
  * As fallback, try `payload.dig("call","serverUrl")` query params.
* Build `TrialCall`:

  * `duration_seconds`, `recording_url`, `transcript` (array of `{role,message,timestamp}`), `callee_phone` from `TrialSession.prospect_phone`.
  * `captured` from **functionCalls** (prefer), else regex from transcript (LeadExtractor).
  * `intent` via **IntentClassifier**.
* Persist (unique `vapi_call_id`).
* **Broadcast** via `TrialSessionChannel`:

  * `prepend` the new CallCard partial into `#trial_calls`.
  * `replace` header counters (calls_used / call_limit).
* Mark event `processed`.

```ruby
class ProcessVapiEventJob < ApplicationJob
  queue_as :default

  def perform(webhook_event_id, meta = {})
    wh = WebhookEvent.find(webhook_event_id)
    return if wh.status == "processed"

    payload = wh.raw
    return unless payload["type"] == "call.ended"

    session_id = meta["sessionId"] || VapiPayload.extract_session_id(payload)
    ts = TrialSession.find(session_id)

    call = payload["call"]
    vapi_call_id = call["id"]

    trial_call = TrialCall.find_or_initialize_by(vapi_call_id:)
    if trial_call.new_record?
      captured = LeadExtractor.from_function_calls(call["functionCalls"]) ||
                 LeadExtractor.from_transcript(call["transcript"])

      intent = IntentClassifier.call(call, ts.scenario_slug)

      trial_call.assign_attributes(
        trial_session_id: ts.id,
        callee_phone: ts.prospect_phone,
        duration_seconds: call["duration"],
        recording_url: call["recordingUrl"],
        transcript: VapiPayload.compact_transcript(call["transcript"]),
        captured: captured,
        scenario_slug: ts.scenario_slug,
        intent: intent
      )
      
      # ⚠️ CRITICAL: Handle race conditions with database constraint
      begin
        trial_call.save!
      rescue ActiveRecord::RecordNotUnique
        # Lost the race, fetch the winner's record
        trial_call = TrialCall.find_by!(vapi_call_id: vapi_call_id)
      end
    end

    # Resync calls_used from DB truth to avoid drift
    ts.update!(calls_used: TrialCall.where(trial_session_id: ts.id).count)

    # Broadcast Turbo updates
    TrialSessionChannel.broadcast_prepend_to(
      ts,
      target: "trial_calls",
      partial: "trial_calls/call",
      locals: { call: trial_call }
    )
    TrialSessionChannel.broadcast_replace_to(
      ts,
      target: "trial_stats",
      partial: "trial_sessions/stats",
      locals: { session: ts }
    )

    wh.update!(status: "processed", processed_at: Time.current)
  rescue => e
    wh.update!(status: "failed") rescue nil
    Sentry.capture_exception(e)
    raise # so Sidekiq retries
  end
end
```

---

## Services (helpers)

```ruby
# app/services/vapi_payload.rb
class VapiPayload
  def self.extract_session_id(payload)
    url = payload.dig("call","serverUrl").to_s
    Rack::Utils.parse_query(URI(url).query)["sessionId"]
  rescue
    nil
  end

  def self.compact_transcript(arr)
    return [] unless arr.is_a?(Array)
    # Trim to last ~200 turns or 10k chars to avoid bloat
    acc = []
    total = 0
    arr.last(200).each do |t|
      msg = t["message"].to_s
      total += msg.length
      break if total > 10_000
      acc << { "role" => t["role"], "message" => msg, "timestamp" => t["timestamp"] }
    end
    acc
  end
end
```

```ruby
# app/services/lead_extractor.rb
class LeadExtractor
  EMAIL_RX = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i
  PHONE_RX = /\+?\d[\d\-\s().]{7,}\d/

  def self.from_function_calls(funcs)
    Array(funcs).reverse_each do |f|
      next unless %w[capture_lead book_appointment].include?(f["name"])
      p = f["parameters"] || {}
      return {
        "name"  => p["name"] || p["customer_name"],
        "phone" => p["phone"] || p["customer_phone"],
        "email" => p["email"],
        "goal"  => p["goal"],
        "time"  => p["preferred_time"]
      }.compact
    end
    nil
  end

  def self.from_transcript(trans)
    text = Array(trans).map { _1["message"] }.join(" ")
    {
      "email" => text[EMAIL_RX],
      "phone" => text[PHONE_RX]
    }.compact
  end
end
```

```ruby
# app/services/intent_classifier.rb
class IntentClassifier
  def self.call(call_payload, default_slug)
    funcs = Array(call_payload["functionCalls"])
    return "lead_intake" if funcs.any? { _1["name"] == "capture_lead" }
    return "scheduling"  if funcs.any? { _1["name"] == "offer_times" }
    # Fallback: keyword probe in transcript
    msg = Array(call_payload["transcript"]).map { _1["message"].downcase }.join(" ")
    return "scheduling"  if msg.include?("book") || msg.include?("appointment")
    return "lead_intake" if msg.include?("interested") || msg.include?("join")
    default_slug.presence || "info"
  end
end
```

*(Optional)* `TranscriptSanitizer` to mask emails/phones in previews before rendering.

---

## Realtime (ActionCable)

* Trial page subscribes to `TrialSessionChannel` keyed by **session** instance.

```ruby
class TrialSessionChannel < ApplicationCable::Channel
  def subscribed
    ts = TrialSession.find_by!(code: params[:code])
    reject unless current_user && ts.user_id == current_user.id
    stream_for ts
  end
end
```

JS subscription (Stimulus) or Turbo Stream tag in the view:

```erb
<%= turbo_stream_from @ts %>
<div id="trial_stats"><%= render "trial_sessions/stats", session: @ts %></div>
<div id="trial_calls"><!-- cards are prepended here --></div>
```

---

## Views (partials)

`app/views/trial_calls/_call.html.erb`

```erb
<div class="card mb-3">
  <div class="card-body">
    <div class="flex items-center justify-between">
      <div class="text-sm opacity-70"><%= time_ago_in_words(call.created_at) %> ago</div>
      <div class="badge"><%= call.intent&.titleize || "Info" %></div>
    </div>

    <div class="mt-2 text-sm">
      <strong>Duration:</strong> <%= number_to_duration(call.duration_seconds) %>
      <% if call.captured.present? %>
        <span class="ml-3"><strong>Captured:</strong>
          <% call.captured.each do |k,v| %>
            <span class="badge mr-1"><%= k %>: <%= v %></span>
          <% end %>
        </span>
      <% end %>
    </div>

    <% if call.recording_url.present? %>
      <audio controls class="w-full mt-2">
        <source src="<%= call.recording_url %>" type="audio/mpeg">
      </audio>
    <% end %>

    <details class="mt-2">
      <summary class="cursor-pointer">Transcript</summary>
      <pre class="whitespace-pre-wrap text-sm mt-1">
<% call.transcript.each do |t| %>
<%= "[#{t["role"][0].upcase}] " %><%= t["message"] %>
<% end %>
      </pre>
    </details>
  </div>
</div>
```

`app/views/trial_sessions/_stats.html.erb`

```erb
<div class="flex items-center gap-3">
  <div class="stat">
    <div class="stat-title">Calls Used</div>
    <div class="stat-value"><%= @session.calls_used %>/<%= @session.call_limit %></div>
  </div>
  <div class="stat">
    <div class="stat-title">Time Limit</div>
    <div class="stat-value"><%= @session.seconds_cap %>s</div>
  </div>
</div>
```

Helper:

```ruby
def number_to_duration(sec)
  m, s = sec.to_i.divmod(60); format("%d:%02d", m, s)
end
```

---

## Retention

* **PurgeOldTrialsJob** (daily):

  * Delete `trial_calls.transcript` content (or entire row) for sessions `status!='converted'` and `created_at < 7.days.ago`.
  * Keep metadata (duration, intent) if you want historical counts.
* Update privacy page: trial data retention 7 days unless converted.

```ruby
class PurgeOldTrialsJob < ApplicationJob
  queue_as :low
  def perform
    TrialCall.joins(:trial_session)
      .where("trial_sessions.status != 'converted'")
      .where("trial_calls.created_at < ?", 7.days.ago)
      .find_each { |c| c.update!(transcript: {}, recording_url: nil, captured: {}) }
  end
end
```

---

## Testing Plan

**Fixtures**

* Store 2–3 sample Vapi webhook JSONs (`spec/fixtures/vapi/call_ended_with_lead.json`, `…_scheduling.json`, `…_info.json`).

**Model specs**

* `TrialCall` validations; unique `vapi_call_id`.
* `WebhookEvent` unique constraint.

**Service specs**

* `VapiPayload.extract_session_id` (serverUrl parsing).
* `LeadExtractor.from_function_calls` & `.from_transcript` (regex).
* `IntentClassifier.call` (func vs keyword fallback).

**Request specs**

* `POST /webhooks/vapi` happy path: 200, `WebhookEvent` created.
* Duplicate webhook → still 200, no extra `TrialCall`.
* Signature/token missing → 401.

**Job specs**

* `ProcessVapiEventJob` creates a `TrialCall`, updates `calls_used`, broadcasts (assert broadcast enqueued).

**System spec**

* Auth → create trial → (simulate assistant ready) → fire webhook fixture → page prepends new call card with intent chip and recording element.
  *(Stub ActionCable or assert turbo stream morphs.)*

**Security**

* Rack::Attack rule lets normal webhook rates through; blocks abusive bursts (e.g., >30/min from same IP) in non-prod.

Coverage for Phase 2 code: **≥ 85%**.

---

## Operational Notes

* **Fast ACK**: webhook controller must not block; all heavy work in `ProcessVapiEventJob`.
* **PII in logs**: never log raw transcript; mask emails/phones if you must log.
* **Timeouts**: do not call external services inside webhook job (you already have data).
* **Backfills**: sync `calls_used` from `trial_calls.count` on each call end to avoid drift if Phase 1 increment failed.

---

## Tickets (copy into tracker)

1. **P2-01 Migrations**: `webhook_events`, `trial_calls` (+ FK, indexes).
   **AC**: schema loads; unique `(provider,event_id)`; unique `vapi_call_id`.
   **Tests**: migration/schema spec.

2. **P2-02 Webhook Controller**: `POST /webhooks/vapi` w/ signature/token, idempotent create, enqueue job.
   **AC**: 200 fast; duplicate safe; bad JSON → 400; unauthorized without token.
   **Tests**: request specs.

3. **P2-03 ProcessVapiEventJob**: parse → upsert TrialCall → resync calls_used → broadcast two Turbo updates.
   **AC**: creates row once; updates stats; broadcasts.
   **Tests**: job spec; broadcast assertion.

4. **P2-04 Services**: `VapiPayload`, `LeadExtractor`, `IntentClassifier`.
   **AC**: handle fixtures; return expected captured+intent.
   **Tests**: unit specs for each.

5. **P2-05 Views**: `_call.html.erb`, `_stats.html.erb`, trial page turbo_stream subscription, audio player.
   **AC**: renders; duration helper; transcript expand/collapse.
   **Tests**: component/feature test.

6. **P2-06 Channel**: `TrialSessionChannel` authz (user owns session).
   **AC**: unauthorized subscriber rejected; owner streams.
   **Tests**: channel spec.

7. **P2-07 PurgeOldTrialsJob**: redact/purge after 7 days for non-converted.
   **AC**: removes transcript/recording; keeps counts.
   **Tests**: time-travel spec.

8. **P2-08 Rack::Attack**: gentle rate-limit on webhook route.
   **AC**: allows normal load; 429 on attack.
   **Tests**: request spec (feature-flagged in test env if needed).

---

## UI Component Specifications

### AudioPlayer Component

**Requirements:**
- Keyboard controls: Space (play/pause), ← → (seek 5s), ↑ ↓ (volume)
- Visual playback progress bar (clickable to seek)
- Current time / total duration display
- Loading state while fetching audio
- Error state if recording unavailable
- ARIA live region announces play/pause state
- Respects `prefers-reduced-motion` (no animations)

**Accessibility:**
- `role="region"` `aria-label="Call recording player"`
- Play button: `aria-label="Play recording"` / `"Pause recording"`
- Seek bar: `role="slider"` `aria-valuemin/max/now/text`
- Keyboard focus visible with 2px offset ring

---

### Transcript Component

**Requirements:**
- Collapsed by default (first 5 user/assistant exchanges shown)
- "[Read more ↓]" button expands full transcript
- Virtualize if >50 exchanges (use stimulus + Intersection Observer)
- Format: `[A]` for assistant, `[U]` for user, timestamp optional
- Copy: "[A] Hi, thanks for calling! How can I help?" each on new line
- Monospace font for readability
- High contrast (WCAG AA: 4.5:1 minimum)

**States:**
- Collapsed: Show preview + expand button
- Expanded: Full transcript, "[Read less ↑]" button
- Loading: Skeleton lines (3-5 gray bars)
- Empty: "Transcript unavailable"

---

## Phase 2 Exit Criteria

**Product:**
- [ ] Trial page live-updates with call mini-report within seconds after hangup
- [ ] Mini-report displays: Captured fields FIRST (above transcript), recording with play button, intent badge
- [ ] Mini-report works flawlessly on mobile (375px): fields visible above fold, play button ≥60px tap target
- [ ] Recording + transcript snippet + captured fields + intent shown
- [ ] Counters accurate; caps respected
- [ ] Audio player keyboard accessible (Space, arrow keys)

**Metrics/SLOs:**
- [ ] Webhook→UI latency <3s P95 (mini-report appearance)
- [ ] No layout shift when mini-report appears (CLS <0.02 measured)
- [ ] TTFC ≤10s P95 maintained
- [ ] Trial call success rate >85%

**Operations:**
- [ ] Webhooks idempotent; retries don't duplicate
- [ ] Webhook path secured; logs free of PII (transcripts never logged)
- [ ] Retention job in place (7-day purge for non-converted trials)
- [ ] CI green; staging E2E verified

**Risks Mitigated:**
- [ ] Webhook race conditions: Concurrent processing handled, unique constraints enforced
- [ ] Data loss: Idempotency prevents duplicate records on retries
- [ ] Poor conversion: Mini-report perfected as conversion driver (captured fields prominent)
- [ ] **Tests (20 total, <60s):** Webhook idempotency + concurrent processing, race conditions, ActionCable broadcasts, system spec for trial→call→mini-report (see Section 12)

---

Want me to generate the **webhook fixtures** and a paste-ready `_call.html.erb` with Tailwind classes to match your design system?

Awesome — here’s **Phase 3: Payments & Conversion (Stripe Checkout → Business)** as a complete, engineer-ready plan. It assumes Phase 1 (magic-link gated trial) and Phase 2 (trial webhooks + mini-report) are shipped.

---

# Phase 3 — Payments & Conversion

## Goal (Definition of Done)

* From the trial page, user clicks **Upgrade**, hits **Stripe Checkout**, pays, and is redirected back.
* On **`checkout.session.completed`**, we **convert** the trial to a real **Business**:

  * Clone the trial’s persona/voice/style/KB and create a **paid Vapi assistant** (no time cap).
  * Create a **Business** record linked to the `User`.
  * Mark trial `status = "converted"`.
  * Mark subscription info: `stripe_customer_id`, `stripe_subscription_id`, `subscription_tier`, `is_unlimited = true`.
  * Send **“Agent Ready”** email and redirect the user to a **Paid Onboarding** shell page.
* **Idempotent** Stripe webhooks; safe on retries.
* **Security**: Stripe signature verification; PII-safe logs.

> Note: **Phone number assignment & live dashboard** are Phase 4. In Phase 3 the user finishes purchase and lands in a simple **Onboarding** page that confirms their assistant is ready and previews “Assign a number” coming next.

---

## Architecture Overview

* New **Stripe adapter** (`StripeClient`) and **checkout controller**.
* New **Stripe webhook** controller using signed verification.
* New **conversion job** (`ConvertTrialToBusinessJob`) that clones assistant and creates `Business`.
* Minimal **Business** model + controller (show/onboarding shell).
* Reuse **webhook_events** table for Stripe idempotency or create a `stripe_events` view onto it.

---

## Data Model (migrations)

### 1) Businesses (new)

```ruby
create_table :businesses, id: :uuid do |t|
  t.uuid   :user_id, null: false, index: true
  t.uuid   :trial_session_id, index: { unique: true } # idempotent conversion link
  t.string :name, null: false
  t.string :vertical, null: false
  t.string :website
  t.string :persona_name
  t.string :voice_id
  t.string :style
  t.jsonb  :kb, null: false, default: {}          # carry from trial
  t.string :vapi_assistant_id                     # paid assistant (no caps)
  t.boolean :is_unlimited, null: false, default: false
  t.string :subscription_tier                     # "starter"
  t.string :stripe_customer_id, index: true
  t.string :stripe_subscription_id, index: { unique: true }
  t.string :stripe_metered_item_id               # For usage reporting (Stripe SubscriptionItem ID)
  t.timestamps
end
add_foreign_key :businesses, :users
add_foreign_key :businesses, :trial_sessions
```

> **Why store `trial_session_id`?** Enables **idempotent conversion** (unique index) and attribution.

### 2) Webhook events (reuse from Phase 2)

If you already have `webhook_events`, reuse with `provider: "stripe"`. Otherwise, add the provider index if not present.

---

## Routes

```ruby
# config/routes.rb
post "/stripe/checkout", to: "stripe_checkout#create"

namespace :webhooks do
  post :stripe, to: "stripe#create"
end

resources :businesses, only: [:show] do
  member do
    get :onboarding  # simple shell page post-purchase
  end
end
```

---

## Stripe Adapter & Config

### ENV

```
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
STRIPE_PRICE_STARTER=price_...
APP_URL=https://beakerai.com
```

### `StripeClient` (adapter)

```ruby
# app/services/stripe_client.rb
class StripeClient
  def initialize(api_key: ENV.fetch("STRIPE_SECRET_KEY"))
    Stripe.api_key = api_key
  end

  def ensure_customer!(user)
    if user.stripe_customer_id.present?
      Stripe::Customer.retrieve(user.stripe_customer_id)
    else
      c = Stripe::Customer.create(email: user.email, metadata: { user_id: user.id })
      user.update!(stripe_customer_id: c.id) rescue nil
      c
    end
  end

  def create_checkout_session!(user:, trial_session:, tier: "starter")
    customer = ensure_customer!(user)
    price_id = price_for(tier)

    Stripe::Checkout::Session.create(
      customer: customer.id,
      mode: "subscription",
      line_items: [{ price: price_id, quantity: 1 }],
      success_url: "#{ENV["APP_URL"]}/businesses/post_purchase?session_id={CHECKOUT_SESSION_ID}",
      cancel_url:  "#{ENV["APP_URL"]}/trial/#{trial_session.code}",
      metadata: {
        user_id: user.id,
        trial_session_id: trial_session.id,
        tier: tier
      }
    )
  end

  def price_for(tier)
    case tier
    when "starter" then ENV.fetch("STRIPE_PRICE_STARTER")
    else
      raise ArgumentError, "unknown tier"
    end
  end
end
```

---

## Controllers

### 1) `StripeCheckoutController#create`

* Auth required.
* Accepts `{trial_code, tier}` and creates Stripe Checkout session.
* Returns `302` to Stripe or JSON `{url}` (depending on fetch style).

```ruby
class StripeCheckoutController < ApplicationController
  before_action :authenticate_user!

  def create
    tier = params[:tier].presence || "starter"
    ts = current_user.trial_sessions.find_by!(code: params.require(:trial_code))

    session = StripeClient.new.create_checkout_session!(
      user: current_user, trial_session: ts, tier: tier
    )
    respond_to do |fmt|
      fmt.html { redirect_to session.url, allow_other_host: true }
      fmt.json { render json: { url: session.url } }
    end
  end
end
```

### 2) `Webhooks::StripeController#create`

* Verify signature with `STRIPE_WEBHOOK_SECRET`.
* Upsert `WebhookEvent(provider:"stripe", event_id)`; enqueue **`ProcessStripeEventJob`**.
* Return `200` immediately.

```ruby
class Webhooks::StripeController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.raw_post
    sig     = request.headers["Stripe-Signature"]
    event   = Stripe::Webhook.construct_event(payload, sig, ENV.fetch("STRIPE_WEBHOOK_SECRET"))

    we = WebhookEvent.create!(
      provider: "stripe", event_id: event.id, raw: event.to_hash, status: "received"
    )
    ProcessStripeEventJob.perform_later(we.id)
    head :ok
  rescue JSON::ParserError, Stripe::SignatureVerificationError
    head :bad_request
  rescue ActiveRecord::RecordNotUnique
    head :ok
  end
end
```

---

## Jobs

### 1) `ProcessStripeEventJob`

* Handle **`checkout.session.completed`** (the key path).
* Extract `user_id`, `trial_session_id`, `tier`, and `subscription` id from event.
* **Idempotent conversion**: if a Business already exists for `trial_session_id` or `stripe_subscription_id`, skip.
* Enqueue **`ConvertTrialToBusinessJob`** with the right IDs.

```ruby
class ProcessStripeEventJob < ApplicationJob
  queue_as :default

  def perform(webhook_event_id)
    we = WebhookEvent.find(webhook_event_id)
    return if we.status == "processed"

    event = we.raw
    case event["type"]
    when "checkout.session.completed"
      data = event["data"]["object"]
      ConvertTrialToBusinessJob.perform_later(
        user_id: data["metadata"]["user_id"],
        trial_session_id: data["metadata"]["trial_session_id"],
        tier: data["metadata"]["tier"],
        stripe_customer_id: data["customer"],
        stripe_subscription_id: data["subscription"],
        checkout_session_id: data["id"]
      )
    when "customer.subscription.deleted"
      # Phase 6+: handle downgrade/cancel
    end

    we.update!(status: "processed", processed_at: Time.current)
  end
end
```

### 2) `ConvertTrialToBusinessJob`

* Clone the trial’s **prompt pack & KB** into a paid assistant.
* Create **Business** with subscription fields; mark trial converted.

```ruby
class ConvertTrialToBusinessJob < ApplicationJob
  queue_as :default
  retry_on StandardError, attempts: 5, wait: :exponentially_longer

  def perform(user_id:, trial_session_id:, tier:, stripe_customer_id:, stripe_subscription_id:, checkout_session_id:)
    user = User.find(user_id)
    ts   = TrialSession.find(trial_session_id)

    # Idempotency: bail if already converted
    if Business.exists?(trial_session_id: ts.id) || Business.exists?(stripe_subscription_id: stripe_subscription_id)
      return
    end

    # Build prompt pack exactly like trial (no caps)
    template = ScenarioTemplate.active.where(vertical: ts.vertical, slug: ts.scenario_slug).order(version: :desc).first!
    pack = PromptBuilder.for_trial(ts, template)

    # Create paid assistant (no callTimeLimitSeconds)
    server_url = Rails.application.routes.url_helpers.webhooks_vapi_url(
      host: ENV.fetch("APP_URL"), trial: nil # paid path (no trial flag)
    )
    paid = VapiClient.new.create_assistant(
      name: "#{ts.persona_name} (#{ts.business_name || ts.vertical.titleize})",
      prompt_pack: pack,
      voice_id: ts.voice_id,
      seconds_cap: nil,       # omit to lift cap
      server_url: server_url  # paid webhooks (Phase 4/5 will consume)
    )

    biz = Business.create!(
      user_id: user.id,
      trial_session_id: ts.id,
      name: ts.business_name.presence || "#{ts.vertical.titleize} Customer",
      vertical: ts.vertical,
      website: ts.website,
      persona_name: ts.persona_name,
      voice_id: ts.voice_id,
      style: ts.style,
      kb: ts.kb || {},
      vapi_assistant_id: paid["id"],
      is_unlimited: true,
      subscription_tier: tier,
      stripe_customer_id: stripe_customer_id,
      stripe_subscription_id: stripe_subscription_id
    )

    ts.update!(status: "converted")
    # Email: agent ready (without phone number yet)
    SendEmailJob.perform_later(
      to: user.email,
      template: "agent-ready",
      data: { business_name: biz.name, next_steps_url: Rails.application.routes.url_helpers.onboarding_business_url(biz) }
    )
  end
end
```

> **Note:** If Vapi requires a **different** payload to “lift caps,” set `seconds_cap` only for trial; omit or set a high value for paid.

---

## UI / Views

### Trial Page Upgrade CTA (Phase 2 page)

* Add an **Upgrade** sticky bar or button.
* POST to `/stripe/checkout` with `{ trial_code, tier: "starter" }`, then redirect to returned URL.
* On success, Stripe redirects to `success_url` (a simple landing we handle via the webhook anyway).

### Businesses#onboarding (shell page)

* Shows: “Payment confirmed. We’re finishing your agent.”
* Polls (or just static) → link to “Assign a phone number” coming in **Phase 4**.
* Display the chosen persona/voice and scenario as confirmation.

---

## Emails

* **agent-ready** (no number yet):

  ```
  Subject: Your Beaker AI agent is ready 🎉

  Hi {{name}},

  We’ve set up your AI phone agent for {{business_name}} with the voice and style you chose.
  Next step: assign a phone number and go live.

  Open onboarding → {{next_steps_url}}

  – Team Beaker
  ```

* Later phases will replace with “number assigned” version.

---

## Security & Idempotency

* **Stripe signature** verified via `STRIPE_WEBHOOK_SECRET`.
* **webhook_events** uniqueness on `(provider, event_id)`; retries safe.
* **Business** uniqueness on `trial_session_id` (unique index) and `stripe_subscription_id` (unique index).
* **Logs** omit full payload; include event id only. Mask emails/phones in logs if printed.

---

## Testing Plan

**Fixtures**

* `spec/fixtures/stripe/checkout_session_completed.json`
* `…/subscription_deleted.json` (for future phases)

**Model specs**

* `Business` validates presence & unique indexes.
* `User` has `stripe_customer_id` optional; validated format (not strictly necessary).

**Service specs**

* `StripeClient#create_checkout_session!` (stub Stripe; assert metadata & URLs).
* `StripeClient#ensure_customer!` (idempotent behavior).

**Request specs**

* `POST /stripe/checkout` requires auth; returns URL; 404 on bad `trial_code`.
* `POST /webhooks/stripe`:

  * With valid signature → 200; `WebhookEvent` created.
  * Invalid signature → 400.

**Job specs**

* `ProcessStripeEventJob` enqueues `ConvertTrialToBusinessJob` with correct params.
* `ConvertTrialToBusinessJob`:

  * Creates Business once (idempotent); copies fields; sets `is_unlimited`.
  * Creates paid assistant (stub Vapi); sets `vapi_assistant_id`.
  * Marks trial converted; sends email.

**System spec**

* Auth user on trial page → click Upgrade → (stub Stripe redirect) → simulate webhook → visit onboarding → sees “agent ready” confirmation.

Coverage ≥ **85%** for Phase 3 code.

---

## Tickets (copy into tracker)

1. **P3-01: Migrations — Businesses table + indexes**
   **AC**: schema with unique `trial_session_id`, unique `stripe_subscription_id`.
   **Tests**: migration/schema spec.

2. **P3-02: StripeClient + ENV**
   **AC**: Adapter creates customer if missing; creates checkout session with metadata.
   **Tests**: unit specs w/ stripe stubs.

3. **P3-03: Checkout endpoint** (`POST /stripe/checkout`)
   **AC**: Auth required; 302 to Stripe; JSON mode returns URL.
   **Tests**: request spec.

4. **P3-04: Stripe webhook controller** (+ signature verify)
   **AC**: Valid signature → 200; duplicates ignored; invalid → 400.
   **Tests**: request spec w/ signed headers.

5. **P3-05: ProcessStripeEventJob**
   **AC**: On `checkout.session.completed`, enqueues Convert job with correct args; marks processed.
   **Tests**: job spec.

6. **P3-06: ConvertTrialToBusinessJob**
   **AC**: Idempotent; creates Business; paid assistant; trial.status→converted; email sent.
   **Tests**: job spec w/ Vapi stub.

7. **P3-07: Businesses Controller (onboarding)**
   **AC**: Auth required; shows confirmation & next steps link.
   **Tests**: request/system spec.

8. **P3-08: Trial page Upgrade CTA**
   **AC**: Button invokes checkout; handles error state.
   **Tests**: system spec stubbing controller to return URL.

9. **P3-09: Rack::Attack throttles on `/stripe/checkout`**
   **AC**: Prevent burst abuse; normal behavior unaffected.
   **Tests**: request spec.

10. **P3-10: Email template “agent-ready”**
    **AC**: Queued on conversion; renders with business name & onboarding link.
    **Tests**: mailer preview/spec.

---

## Non-Functional Targets

* **Conversion latency**: webhook → business created ≤ 5s (job async).
* **Reliability**: webhook retries safe; conversion job retries exponential; Vapi errors captured in Sentry.
* **Observability**: log `event_id`, `trial_session_id`, `business_id`; no PII.

---

## Phase 3 Exit Criteria

**Product:**
- [ ] Upgrade from trial triggers Stripe Checkout and succeeds
- [ ] Webhook converts trial to Business idempotently; paid assistant created (no time caps)
- [ ] User receives "agent ready" email and can open onboarding page
- [ ] Onboarding page displays chosen persona/voice/scenario as confirmation
- [ ] Fixed subscription pricing only ($199 or $499/mo) — usage metering deferred to Phase 6

**Metrics/SLOs:**
- [ ] Conversion latency: Webhook → Business created ≤5s
- [ ] Trial→Paid conversion rate tracked (target >15%)
- [ ] Payment success rate >99% (excluding user card errors)

**Operations:**
- [ ] No duplicate businesses on webhook retries (unique constraints verified)
- [ ] Stripe webhook signature verification working
- [ ] CI green; staging tested end-to-end
- [ ] Sentry logs conversion errors with context (event_id, trial_session_id, business_id)

**Risks Mitigated:**
- [ ] Payment failures: Idempotent conversion, race conditions prevented
- [ ] Revenue loss: No duplicate charges, webhook retries safe
- [ ] Debugging: Conversion path traceable via logs and webhook events table
- [ ] **Tests (15 total, <90s):** Stripe webhook idempotency, payment flow, concurrent `ConvertTrialToBusinessJob`, system spec for trial→upgrade→onboarding (see Section 12)

---

If you want, I can draft **paste-ready** versions of the migrations, controllers, jobs, and a stub `StripeClient` spec to drop into your repo so your team can open a PR for Phase 3 today.
Awesome — here’s **Phase 4: Paid Number & Dashboard Shell** as a complete, engineer-ready plan. It assumes Phase 1–3 are shipped (magic-link trial, mini-report via Vapi webhooks, Stripe conversion to a `Business` with a paid assistant). This phase gives paying users “their” phone number and a live dashboard that updates in real time for paid calls.

---

# Phase 4 — Paid Number & Dashboard Shell

## Goal (Definition of Done)

* A converted user visits **Onboarding** and clicks **Assign Number** → we **buy a Twilio number** and bind it to their **paid Vapi assistant**.
* Inbound calls to that number are handled by Vapi and **logged in our `calls` table** via our **paid Vapi webhook**.
* The **Business Dashboard** shows number, live **Recent Calls** (▶ recording + transcript snippet + captured fields), and a couple of top-line stats. Updates arrive **in real time** via **ActionCable**.

> ⚠️ **COMPLIANCE TIMING CRITICAL**: Phase 4.5 (Compliance & Guardrails) MUST run IN PARALLEL with Phase 4. Launching paid outbound calling without DNC checks, quiet hours, and consent logging creates $500-$1,500 per call TCPA exposure. DO NOT ship Phase 4 without Phase 4.5.

---

## Architecture Overview

* New **Twilio adapter** and **number provisioning job**.
* Extend **Vapi webhook** path to handle paid calls (`business_id` correlation).
* Add **`calls` table**, **BusinessChannel**, and **Dashboard** UI.
* Optional improvement: **update paid assistant `serverUrl`** to include `businessId` (if Phase 3 created it without).

---

## Data Model

### 1) `calls` (paid call logs)

```ruby
create_table :calls, id: :uuid do |t|
  t.uuid   :business_id, null: false, index: true
  t.string :vapi_call_id, null: false, index: { unique: true }
  t.string :caller_phone
  t.integer :duration_seconds
  t.string :recording_url
  t.jsonb  :transcript, null: false, default: {}  # [{role, message, timestamp}]
  t.jsonb  :captured,   null: false, default: {}  # {name, phone, email, goal, time}
  t.string :intent                                     # booked|lead_intake|scheduling|info|other
  t.timestamps
end
add_foreign_key :calls, :businesses
```

> Mirrors `trial_calls` but tied to `Business`.

### 2) `businesses` (small additions if missing)

Ensure these columns exist:

* `phone_number:string` (the Twilio number, E.164)
* `vapi_assistant_id:string` (already set in Phase 3)
* Unique index on `stripe_subscription_id` already added in Phase 3.

---

## Routes

```ruby
# config/routes.rb
resources :businesses, only: [:show] do
  member do
    get  :dashboard          # /businesses/:id/dashboard
    post :assign_number      # buy and attach a Twilio number
  end
end

namespace :webhooks do
  post :vapi, to: "vapi#create"   # already exists (trial + paid)
end
```

---

## Controllers

### 1) `BusinessesController`

* `dashboard` (auth required, owner only): shows number, quick stats, and live recent calls list; subscribes to `BusinessChannel`.
* `assign_number` (POST): enqueues `AssignTwilioNumberJob` with optional params (e.g., `area_code`); returns 202 and updates dashboard via Turbo when done.

```ruby
class BusinessesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_business, only: [:dashboard, :assign_number]

  def dashboard
    authorize! @business  # Pundit/ActionPolicy
    @recent_calls = @business.calls.order(created_at: :desc).limit(20)
  end

  def assign_number
    authorize! @business
    AssignTwilioNumberJob.perform_later(@business.id, params.permit(:area_code).to_h)
    head :accepted
  end

  private
  def set_business
    @business = current_user.businesses.find(params[:id])
  end
end
```

---

## Services (Adapters)

### 1) `TwilioClient`

```ruby
# app/services/twilio_client.rb
class TwilioClient
  # Interface:
  # - buy_local_number!(area_code:, voice_url:) → returns E.164 phone number
  # - update_number_webhook!(phone_number:, voice_url:) → updates existing number
  #
  # Implementation: Use Twilio REST client gem
  # Timeouts: 5s connect, 15s operation (see Section 7 env vars)
  # Errors: Raise domain-specific errors (TwilioNumberUnavailable, etc.)
  # Circuit breaker: Wrap in Stoplight(:twilio) pattern (see VapiClient example)
end
```

> For MVP, we set Twilio **Voice URL directly to Vapi’s phone endpoint**, e.g. `https://api.vapi.ai/call/phone/<assistant_id>`. This keeps our app out of the media path and relies on **Vapi webhooks** for logging.

### 2) `VapiClient` additions

Add an **update assistant** endpoint if you need to patch `serverUrl` after the `Business` exists.

```ruby
def update_assistant(assistant_id:, server_url:)
  body = { serverUrl: server_url }
  parse @http.patch("#{BASE}/assistant/#{assistant_id}", json: body)
end
```

---

## Jobs

### 1) `AssignTwilioNumberJob`

* Picks an area code (default guess from last trial `prospect_phone` or fallback).
* Buys a number and configures **Voice URL → Vapi phone bridge** for the **paid assistant**.
* Updates `business.phone_number`.
* **Optional**: Patch assistant `serverUrl` to include `businessId` in Vapi webhook callbacks (see next job).
* Broadcast a Turbo update to the dashboard (number display + status toast).

```ruby
class AssignTwilioNumberJob < ApplicationJob
  queue_as :default
  retry_on StandardError, attempts: 3, wait: :exponentially_longer

  def perform(business_id, opts = {})
    biz = Business.find(business_id)
    area_code = opts["area_code"].presence || default_area_code_for(biz)

    vapi_assistant_id = biz.vapi_assistant_id.presence or raise "No assistant"
    voice_url = "https://api.vapi.ai/call/phone/#{vapi_assistant_id}"

    number = TwilioClient.new.buy_local_number!(area_code: area_code, voice_url: voice_url)
    biz.update!(phone_number: number)

    # Strongly recommended: ensure paid assistant webhooks carry businessId
    UpdateAssistantServerUrlJob.perform_later(business_id)

    BusinessChannel.broadcast_replace_to(
      biz, target: "business_number",
      partial: "businesses/number", locals: { business: biz }
    )
  end

  private
  def default_area_code_for(biz)
    # naive: try to reuse trial phone’s area code if present; else 415
    if (p = biz.user.trial_sessions.order(created_at: :desc).first&.prospect_phone).present?
      p.gsub(/\D/,'')[0,3]
    else
      "415"
    end
  end
end
```

### 2) `UpdateAssistantServerUrlJob` (optional but best-practice)

* Ensures Vapi webhooks include `businessId` for easy correlation.

```ruby
class UpdateAssistantServerUrlJob < ApplicationJob
  queue_as :default

  def perform(business_id)
    biz = Business.find(business_id)
    server_url = Rails.application.routes.url_helpers.webhooks_vapi_url(
      host: ENV.fetch("APP_URL"),
      businessId: biz.id
    )
    VapiClient.new.update_assistant(biz.vapi_assistant_id, server_url: server_url)
  end
end
```

---

## Webhooks: Paid Vapi Call Logging

Extend **`Webhooks::VapiController`** (from Phase 2) to handle the **paid** path (no `trial=1`). We’ll reuse `webhook_events` for idempotency and **ProcessVapiEventJob** style, but create **`calls`** instead of `trial_calls`.

```ruby
# app/jobs/process_vapi_event_job.rb (extend)
class ProcessVapiEventJob < ApplicationJob
  queue_as :default

  def perform(webhook_event_id, meta = {})
    wh = WebhookEvent.find(webhook_event_id)
    return if wh.status == "processed"

    payload = wh.raw
    type    = payload["type"]

    if type == "call.ended"
      if meta["trial"] == "1" || VapiPayload.trial?(payload)
        process_trial(payload, meta)
      else
        process_paid(payload, meta)
      end
    end

    wh.update!(status: "processed", processed_at: Time.current)
  end

  private

  def process_paid(payload, meta)
    business_id = meta["businessId"] || VapiPayload.extract_business_id(payload)
    biz = Business.find(business_id)

    call = payload["call"]
    vapi_call_id = call["id"]

    record = Call.find_or_initialize_by(vapi_call_id: vapi_call_id)
    if record.new_record?
      captured = LeadExtractor.from_function_calls(call["functionCalls"]) ||
                 LeadExtractor.from_transcript(call["transcript"])
      intent = IntentClassifier.call(call, nil)

      record.assign_attributes(
        business_id: biz.id,
        caller_phone: call["phoneNumber"],     # Vapi includes inbound caller
        duration_seconds: call["duration"],
        recording_url: call["recordingUrl"],
        transcript: VapiPayload.compact_transcript(call["transcript"]),
        captured: captured,
        intent: intent
      )
      
      # ⚠️ CRITICAL: Handle race conditions with database constraint
      begin
        record.save!
      rescue ActiveRecord::RecordNotUnique
        # Lost the race, fetch the winner's record
        record = Call.find_by!(vapi_call_id: vapi_call_id)
      end
    end

    BusinessChannel.broadcast_prepend_to(
      biz, target: "business_calls",
      partial: "calls/call", locals: { call: record }
    )
    BusinessChannel.broadcast_replace_to(
      biz, target: "business_stats",
      partial: "businesses/stats", locals: { business: biz }
    )
  end
end
```

**Helpers (VapiPayload additions)**

```ruby
class VapiPayload
  def self.extract_business_id(payload)
    url = payload.dig("call","serverUrl").to_s
    Rack::Utils.parse_query(URI(url).query)["businessId"]
  rescue
    nil
  end
  def self.trial?(payload)
    url = payload.dig("call","serverUrl").to_s
    q   = Rack::Utils.parse_query(URI(url).query)
    q["trial"].present?
  rescue
    false
  end
end
```

---

## Realtime (ActionCable)

### Channel

```ruby
class BusinessChannel < ApplicationCable::Channel
  def subscribed
    biz = Business.find(params[:id])
    reject unless current_user && biz.user_id == current_user.id
    stream_for biz
  end
end
```

### Dashboard View

```erb
<%= turbo_stream_from @business %>

<div id="business_number">
  <%= render "businesses/number", business: @business %>
</div>

<div id="business_stats">
  <%= render "businesses/stats", business: @business %>
</div>

<div id="business_calls">
  <% @recent_calls.each do |call| %>
    <%= render "calls/call", call: call %>
  <% end %>
</div>
```

**`_number.html.erb`**

```erb
<div class="card p-4">
  <div class="flex items-center justify-between">
    <div>
      <div class="text-sm opacity-70">Your number</div>
      <div class="text-2xl font-semibold"><%= @business.phone_number || "Not assigned" %></div>
    </div>
    <% if @business.phone_number.blank? %>
      <%= button_to "Assign Number", assign_number_business_path(@business), method: :post,
            class: "btn btn-primary" %>
    <% end %>
  </div>
  <p class="mt-2 text-sm">
    Share this with customers to start receiving calls.
  </p>
</div>
```

**`_stats.html.erb`** (simple MVP)

```erb
<div class="grid grid-cols-2 gap-3">
  <div class="stat">
    <div class="stat-title">Calls (7d)</div>
    <div class="stat-value"><%= @business.calls.where("created_at > ?", 7.days.ago).count %></div>
  </div>
  <div class="stat">
    <div class="stat-title">Avg Duration</div>
    <div class="stat-value">
      <% secs = @business.calls.where("created_at > ?", 7.days.ago).average(:duration_seconds).to_i %>
      <%= number_to_duration(secs) %>
    </div>
  </div>
</div>
```

**`calls/_call.html.erb`** (reuse style from Phase 2)

```erb
<div class="card mb-3">
  <div class="card-body">
    <div class="flex items-center justify-between">
      <div class="text-sm opacity-70"><%= time_ago_in_words(call.created_at) %> ago</div>
      <div class="badge"><%= (call.intent || "info").titleize %></div>
    </div>
    <div class="mt-2 text-sm">
      <strong>From:</strong> <%= call.caller_phone %>
      <span class="ml-3"><strong>Duration:</strong> <%= number_to_duration(call.duration_seconds) %></span>
    </div>
    <% if call.captured.present? %>
      <div class="mt-1 text-sm">
        <strong>Captured:</strong>
        <% call.captured.each { |k,v| %><span class="badge mr-1"><%= k %>: <%= v %></span><% } %>
      </div>
    <% end %>
    <% if call.recording_url.present? %>
      <audio controls class="w-full mt-2"><source src="<%= call.recording_url %>" type="audio/mpeg"></audio>
    <% end %>
    <details class="mt-2">
      <summary class="cursor-pointer">Transcript</summary>
      <pre class="whitespace-pre-wrap text-sm mt-1">
<% call.transcript.each do |t| %>
<%= "[#{t["role"][0].upcase}] " %><%= t["message"] %>
<% end %>
      </pre>
    </details>
  </div>
</div>
```

---

## Security, Idempotency & Compliance

* **Twilio**: no inbound webhook to your app needed for MVP; set Twilio number’s **Voice URL directly to Vapi**. Lock down Twilio account with strong auth/SCM.
* **Vapi**: keep **HMAC/token verification** on your webhook (as in Phase 2).
* **Idempotency**: keep using `webhook_events(provider, event_id)` unique constraint.
* **PII**: do not log raw transcripts; sanitize before logging. Provide 7-day purge for non-essential data if needed (Phase 2 job can be extended for `calls` as well).
* **Quiet hours**: apply to **outbound** only; inbound always accepted.

---

## Testing Plan

**Fixtures**

* Paid Vapi `call.ended` payload with `phoneNumber` populated.

**Model specs**

* `Call` validates presence; unique `vapi_call_id`.

**Service specs**

* `TwilioClient#buy_local_number!` happy/empty results (stub Twilio).
* `VapiClient#update_assistant` (stub HTTP).

**Job specs**

* `AssignTwilioNumberJob`: buys number, updates business, broadcasts.
* `ProcessVapiEventJob#process_paid`: creates `Call`, broadcasts twice, idempotent.

**Request specs**

* `POST /businesses/:id/assign_number`: auth required; returns 202; 404 for others’ business.
* `POST /webhooks/vapi`: paid path, token verified → 200; creates call row.

**System spec**

* User logs in, visits `/businesses/:id/dashboard`, clicks **Assign Number**, sees number appear; post webhook fixture; sees new call card prepended.

Coverage target for Phase 4 code: **≥85%**.

---

## Tickets (copy into tracker)

1. **P4-01: Lightweight Admin Panel (Critical for Operations)**
   **What/Why**: Need admin tools immediately after first paid customer to diagnose/fix conversion failures.
   **AC**: List webhook_events by status; manually reprocess failed events; view Business/Call/Lead records; Sidekiq queue inspection.
   **Tests**: Request spec: admin-only access; reprocess webhook triggers job.
   **Tools**: Use Avo, Trestle, or Administrate gem.
   **Priority**: CRITICAL - Required before Phase 4 launch.

2. **P4-02: Migration — `calls` table**
   **AC**: schema present; FK to `businesses`; unique `vapi_call_id`.
   **Tests**: migration/schema spec.

3. **P4-03: TwilioClient** (buy/update number)
   **AC**: supports `buy_local_number!` and `update_number_webhook!`.
   **Tests**: unit specs w/ Twilio stubs.

4. **P4-04: AssignTwilioNumberJob**
   **AC**: purchases number, sets Twilio voice URL to Vapi, updates `business.phone_number`, broadcasts.
   **Tests**: job spec.

5. **P4-05: UpdateAssistantServerUrlJob** (optional but recommended)
   **AC**: patches paid assistant `serverUrl` to include `businessId`.
   **Tests**: job spec with Vapi stub.

6. **P4-06: Webhook paid processing**
   **AC**: `ProcessVapiEventJob` creates `Call` for paid path; idempotent; broadcasts.
   **Tests**: job spec and request spec.

7. **P4-07: BusinessChannel**
   **AC**: only owner can subscribe; broadcasts received.
   **Tests**: channel spec.

8. **P4-08: Dashboard UI + Usage Alerts**
   **What/Why**: Core dashboard with real-time usage monitoring to prevent bill shock.
   **AC**: Shows number component, stats, recent calls; usage alerts at 80%/100% of quota; overage amount displayed in real-time; turbo updates work for all components.
   **Tests**: System spec for dashboard; request spec for usage calculation; component spec for alert variants (80%, 100%, 120%).
   **UI Requirements**: See "Dashboard UI Specifications → Usage & Overage Alerts"

9. **P4-09: Rack::Attack tweaks**
   **AC**: allow webhook burst; limit assign_number POSTs per user (e.g., 5/hour).
   **Tests**: request spec.

10. **P4-10: Cost Monitoring & Alerts**
    **What/Why**: Prevent cost overruns from trial abuse or runaway usage.
    **AC**: Daily job flags businesses exceeding expected usage; budget alerts in Vapi/Twilio dashboards; kill switch to pause calls if costs spike.
    **Tests**: Job spec with usage threshold breach; alert sent.

11. **P4-11: Email "number assigned" (optional polish)**
    **AC**: after job success, email user with their new number and tips.
    **Tests**: mailer spec.

---

## Non-Functional Targets

* **Number assignment**: ≤ 10s (Twilio API round-trip).
* **Webhook to dashboard card**: ≤ 3s from call end.
* **Zero data loss** on webhook retries; duplicates prevented via unique keys.
* **Cost control**: per-business numbers only after payment (Phase 3).

---

## Environment Variables

```
# Twilio
TWILIO_ACCOUNT_SID=AC...
TWILIO_AUTH_TOKEN=...
# Outbound demo number remains from Phase 1: DEMO_OUTBOUND_NUMBER

# Vapi
VAPI_API_KEY=...
VAPI_WEBHOOK_SECRET=...

# App
APP_URL=https://beakerai.com
```

---

## Dashboard UI Specifications

### Layout (Responsive Grid)

**Desktop (1024px+):**
```
┌─────────────┬─────────────────────────────────────┐
│             │ [Your Number: +1 555...] [Copy]    │
│  Sidebar    │                                     │
│  Nav        │ ┌──────┐ ┌──────┐ ┌──────┐        │
│             │ │Calls │ │Leads │ │Booked│        │
│  Dashboard  │ └──────┘ └──────┘ └──────┘        │
│  Leads      │                                     │
│  Analytics  │ Recent Calls                        │
│  Settings   │ [Table with streaming updates]      │
│             │                                     │
└─────────────┴─────────────────────────────────────┘
```

**Mobile (375px):**
```
┌─────────────────────────────────┐
│ [Bottom Nav: Dash|Leads|Settings]│
│                                 │
│ [Your Number] [Copy]            │
│                                 │
│ ┌─────┐                        │
│ │Calls│  (stacked vertically)   │
│ └─────┘                        │
│ ┌─────┐                        │
│ │Leads│                        │
│ └─────┘                        │
│                                 │
│ Recent Calls (list, not table)  │
└─────────────────────────────────┘
```

### KPI StatTile Component

**Layout:**
```
┌───────────────────┐
│ Calls Today       │ ← Label (muted text)
│ 23                │ ← Value (large, bold)
│ ↑ 12% vs yesterday│ ← Trend (success/warn color)
└───────────────────┘
```

**Variants:** default, success (green trend), warn (yellow), danger (red)

---

### Usage & Overage Alerts

**Purpose:** Prevent bill shock by alerting users as they approach/exceed included call quotas.

**80% Warning Alert:**
```
┌─────────────────────────────────────────────┐
│ ⚠️ Usage Alert                              │
│                                             │
│ You've used 80 of 100 included calls       │
│ this month.                                 │
│                                             │
│ Overage rate: $1.50/call                    │
│ [View Usage Details]                        │
└─────────────────────────────────────────────┘
```

**100% Overage Alert (Active):**
```
┌─────────────────────────────────────────────┐
│ 📊 Overage Billing Active                   │
│                                             │
│ Calls this month: 125 / 100 included       │
│ Current overage: 25 calls × $1.50 = $37.50 │
│                                             │
│ Your next invoice will include this charge.│
│ [Upgrade to Pro] [View Invoice Preview]    │
└─────────────────────────────────────────────┘
```

**Implementation Requirements:**
- Alert displays above KPI tiles when `calls_this_month >= included_calls * 0.8`
- Updates in real-time via Turbo Stream on each call completion
- Dismissible but reappears on page refresh until usage drops
- Color coding: yellow at 80%, orange at 100%, red at 120%
- "Upgrade to Pro" CTA only shown for Starter tier users

---

### Empty States

**No calls yet:**
```
┌─────────────────────────────────┐
│      [Phone Icon]               │
│                                 │
│   No calls yet                  │
│   Share your lead form or       │
│   wait for inbound calls        │
│                                 │
│   [Copy Lead Form Link]         │
└─────────────────────────────────┘
```

**Number not assigned:**
```
┌─────────────────────────────────┐
│   📞 No phone number            │
│                                 │
│   Assign a number to start      │
│   receiving calls               │
│                                 │
│   [Assign Number Now →]         │
└─────────────────────────────────┘
```

---

### Loading States (Skeleton Screens)

Use skeleton placeholders to prevent layout shift:

```html
<div class="animate-pulse space-y-4">
  <div class="h-24 bg-gray-200 rounded"></div>
  <div class="grid grid-cols-3 gap-4">
    <div class="h-32 bg-gray-200 rounded"></div>
    <div class="h-32 bg-gray-200 rounded"></div>
    <div class="h-32 bg-gray-200 rounded"></div>
  </div>
</div>
```

Reserve exact heights to prevent CLS when real data loads.

---

## Phase 4 Exit Criteria

**Product:**
- [ ] **Admin panel (P4-01) shipped FIRST** — Webhook inspection, event reprocessing, entity search operational
- [ ] Paid user can click **Assign Number** and receive a Twilio number bound to their Vapi assistant
- [ ] Inbound calls to that number are handled by Vapi and appear in the **Business Dashboard**
- [ ] Dashboard displays: recording, transcript, captured fields, intent badge
- [ ] Dashboard mobile-responsive (375px tested); touch targets ≥44px
- [ ] Usage alerts working: 80% warning, 100% overage display with current charges
- [ ] Empty states implemented (no calls, no number assigned)

**Metrics/SLOs:**
- [ ] Number assignment ≤10s (Twilio API round-trip)
- [ ] Webhook→dashboard card latency <3s P95
- [ ] Week 1 success rate >40% (number assigned + form shared + 2+ dashboard views)
- [ ] Dashboard load time <500ms with 50 calls

**Operations:**
- [ ] Dashboard updates live via Turbo Streams (real-time call prepends working)
- [ ] Idempotent webhooks; secure token verification
- [ ] Admin panel accessible; webhook reprocessing tested
- [ ] No SSH required for debugging conversion failures or webhook issues
- [ ] CI green; staging E2E verified (assign number → place real test call → see on dashboard)

**Risks Mitigated:**
- [ ] First conversion failure debuggable: Admin panel allows webhook inspection without SSH
- [ ] Bill shock prevented: Usage alerts at 80%/100% with overage calculation
- [ ] Webhook race conditions: Paid call processing idempotent, concurrent-safe
- [ ] **Phase 4.5 compliance started IN PARALLEL** — DNC, quiet hours, consent work underway (NOT deferred)

---

If you want, I can also provide paste-ready ERB partials and a Twilio VCR cassette seed so your team can run the Phase 4 test suite without live credentials.
Awesome — here’s **Phase 5: Scenario Engine (paid) + Hosted Lead Form (“Speed-to-Lead”)** as a complete, engineer-ready plan. It assumes Phases 1–4 are shipped (magic-link trials, trial webhooks, Stripe conversion, paid number + dashboard).

---

# Phase 5 — Scenario Engine (Paid) & Hosted Lead Form

## Goal (Definition of Done)

* The same **scenario packs** used in trials now power **paid** assistants.
* Each Business can choose a **default scenario** (Lead Intake, Scheduling, Info).
* Provide a **hosted lead form** (`/l/:slug`) a business can share/put on their site.
  On submit we:

  1. create/update a **Lead** record with UTM attribution,
  2. **call the lead immediately** with the Business’s paid assistant (Speed-to-Lead),
  3. log the call and **link it to the Lead**, and
  4. notify the owner (email).
* Dashboard gets a **Leads** tab (list + detail) and KPI tiles (Leads this week, Speed-to-ring, Booked ratio).
* Idempotency, throttles, spam protections (hCaptcha optional), PII-safe logs, 7-day purge policy consistent with trials.

---

## Architecture Overview

* **Models**: `leads`, `lead_sources`; extend `calls` with `lead_id`.
* **Controllers**: Public **LeadFormsController** (`/l/:slug`), internal **LeadsController** (dashboard).
* **Jobs**: `SpeedToLeadJob` (outbound call), `UpsertLeadFromFunctionCallJob` (webhook side).
* **Services**: reuse `LeadExtractor`, `IntentClassifier`; add `LeadNormalizer` & `LeadDeduper`.
* **Webhooks**: extend paid Vapi processing to **attach/update leads** on `capture_lead` tool calls.
* **Views**: Leads tab, Lead detail, hosted form.
* **Security**: consent checkbox, basic throttles, optional hCaptcha; CSRF on POST form; CORS not needed for hosted.

---

## Data Model (migrations)

### 1) `lead_sources`

```ruby
create_table :lead_sources, id: :uuid do |t|
  t.uuid   :business_id, null: false, index: true
  t.string :slug,        null: false                  # "hosted_form", "ads_form", ...
  t.string :name,        null: false                  # "Hosted Form"
  t.jsonb  :config,      null: false, default: {}     # {slug:"peak-fitness", fields: [...]}
  t.timestamps
  t.index [:business_id, :slug], unique: true
end
add_foreign_key :lead_sources, :businesses
```

### 2) `leads`

```ruby
create_table :leads, id: :uuid do |t|
  t.uuid   :business_id,   null: false, index: true
  t.uuid   :lead_source_id, index: true
  t.string :external_id                                 # if coming from Zapier, etc.
  t.string :name
  t.string :email
  t.string :phone
  t.string :channel                                     # "web", "phone", "ads"
  t.string :status, null: false, default: "new"         # enum: new|contacted|qualified|booked|lost
  t.jsonb  :payload, null: false, default: {}           # raw form payload/UTM
  t.datetime :first_contacted_at
  t.datetime :last_contacted_at
  t.timestamps
  t.index [:business_id, :email], unique: true, where: "email IS NOT NULL"
  t.index [:business_id, :phone], unique: true, where: "phone IS NOT NULL"
end
add_foreign_key :leads, :businesses
add_foreign_key :leads, :lead_sources
```

### 3) `calls` (add linkage)

```ruby
change_table :calls do |t|
  t.uuid :lead_id, index: true
end
add_foreign_key :calls, :leads
```

### 4) `businesses` (preferences)

```ruby
change_table :businesses do |t|
  t.string :default_scenario_slug, null: false, default: "lead_intake"
  t.jsonb  :scenario_settings, null: false, default: {}  # future toggles
end
```

---

## Scenario Engine (paid)

* **Assistant content** for paid calls already created in Phase 3 from the trial template.
* In Phase 5 we ensure **tools** in prompt pack match production needs:

  * `capture_lead` (name, phone, email, goal)
  * `offer_times` (options: [strings]) — still simulated; real calendar comes later
* **Default scenario** is selected on the Business and shown on Dashboard.
  (Changing it triggers `UpdateAssistantServerUrlJob` if you encode scenario into URL; otherwise recreate assistant in Phase 6.)

---

## Hosted Lead Form

### Concept

A public URL per Business: `/l/:slug` (slug stored in `lead_sources.config.slug`), simple HTML form:

* Fields: name, phone (required), email (optional), goal (textarea), consent checkbox.
* Hidden: UTM fields via query (`utm_source`, etc.).
* On submit: create/update Lead, enqueue **SpeedToLeadJob** (outbound call to `phone`), redirect to Thank-you page.

### Routes

```ruby
# Public
get  "/l/:slug",     to: "lead_forms#new",    as: :lead_form
post "/l/:slug",     to: "lead_forms#create", as: :lead_form_submit
get  "/l/:slug/ok",  to: "lead_forms#thanks", as: :lead_form_thanks

# Dashboard
resources :businesses, only: [] do
  resources :leads, only: [:index, :show, :update]
  patch :settings, on: :member  # for default_scenario change
end
```

### Controller: `LeadFormsController`

```ruby
class LeadFormsController < ApplicationController
  protect_from_forgery with: :exception

  def new
    @source = LeadSource.includes(:business).find_by!("config ->> 'slug' = ?", params[:slug])
    @business = @source.business
  end

  def create
    @source = LeadSource.includes(:business).find_by!("config ->> 'slug' = ?", params[:slug])
    biz      = @source.business
    consent  = ActiveModel::Type::Boolean.new.cast(params[:consent])
    return redirect_to lead_form_path(params[:slug]), alert: "Please consent to be contacted." unless consent

    lead = Leads::Upsert.call(
      business: biz,
      lead_source: @source,
      attrs: {
        name: params[:name],
        email: params[:email],
        phone: params[:phone],
        channel: "web",
        payload: params.permit(:goal, :utm_source, :utm_medium, :utm_campaign, :utm_term, :utm_content).to_h
      }
    )

    SpeedToLeadJob.perform_later(biz.id, lead.id)
    redirect_to lead_form_thanks_path(params[:slug])
  end

  def thanks; end
end
```

### Service: `Leads::Upsert`

```ruby
module Leads
  class Upsert
    def self.call(business:, lead_source:, attrs:)
      normalized = LeadNormalizer.normalize(attrs)
      lead = Lead.find_by(business_id: business.id, phone: normalized[:phone]) ||
             (normalized[:email].present? && Lead.find_by(business_id: business.id, email: normalized[:email]))

      if lead
        lead.update!(payload: lead.payload.merge(normalized[:payload] || {}), lead_source_id: lead_source.id)
      else
        lead = business.leads.create!(normalized.merge(lead_source_id: lead_source.id, status: "new"))
      end
      lead
    end
  end
end
```

### Helpers: `LeadNormalizer`, `LeadDeduper`

```ruby
class LeadNormalizer
  def self.normalize(attrs)
    phone = attrs[:phone].to_s.gsub(/\D/, "")
    phone = "+1#{phone}" if phone.present? && !phone.start_with?("+")
    attrs.merge(phone: phone.presence)
  end
end
```

---

## Speed-to-Lead (outbound call)

### QuietHours (TCPA-compliant, timezone-aware)

> ⚠️ **TCPA CRITICAL**: Enforcing quiet hours on business timezone instead of recipient timezone is a TCPA violation. Example: NYC business calling LA lead at 8:30 AM EST = 5:30 AM PST = violation. Always derive timezone from phone number's area code.

```ruby
# ⚠️ CRITICAL: Quiet hours MUST be enforced on RECIPIENT's local time, not business time
# TCPA violations: $500-$1,500 per call
module QuietHours
  START = 8; END = 21  # 8am - 9pm local time
  
  def self.allow?(e164_phone)
    # Derive timezone from area code (use phonelib gem or area code mapping)
    tz = PhoneTimezone.lookup(e164_phone) || "America/Chicago"  # fallback
    local_hour = Time.current.in_time_zone(tz).hour
    local_hour >= START && local_hour < END
  end
end

# app/services/phone_timezone.rb
class PhoneTimezone
  # Map area codes to timezones (simplified - use phonelib in production)
  AREA_CODE_TZ = {
    '212' => 'America/New_York',
    '310' => 'America/Los_Angeles',
    '312' => 'America/Chicago',
    # ... complete mapping
  }.freeze
  
  def self.lookup(e164_phone)
    area_code = e164_phone.gsub(/\D/, '')[1..3]  # Extract area code
    AREA_CODE_TZ[area_code] || 'America/Chicago'
  end
end
```

### Job: `SpeedToLeadJob`

* Preconditions: has phone; Business has `vapi_assistant_id`; quiet hours optional (recommend allow but add copy on form).
* Action: call the lead immediately; set `first_contacted_at/last_contacted_at`; create a lightweight **pending Call** row or rely on webhook to create it later (simpler: rely on webhook).

```ruby
class SpeedToLeadJob < ApplicationJob
  queue_as :default
  retry_on StandardError, attempts: 3, wait: :exponentially_longer

  def perform(business_id, lead_id)
    biz = Business.find(business_id)
    lead = biz.leads.find(lead_id)
    raise "missing phone" if lead.phone.blank?
    VapiClient.new.outbound_call(
      assistant_id: biz.vapi_assistant_id,
      to: lead.phone,
      from: biz.phone_number.presence || ENV.fetch("DEMO_OUTBOUND_NUMBER")
    )
    lead.update!(first_contacted_at: Time.current) if lead.first_contacted_at.nil?
    lead.update!(last_contacted_at: Time.current)
  end
end
```

---

## Webhooks (paid) — Link calls to leads & update lead status

Extend `ProcessVapiEventJob#process_paid`:

* Find `Business` as in Phase 4.
* Try to **attach to a Lead**:

  * By function call `capture_lead` parameters (phone/email) → upsert Lead (same service).
  * Else by `caller_phone` when inbound (if matches an existing Lead).
* Update `leads.status`:

  * If `capture_lead` present → `contacted` (or `qualified` when sufficient fields).
  * If `offer_times` present → `booked` (simulated).
* Save `calls.lead_id = lead.id`.
* Notify owner (email) on new lead.

```ruby
def process_paid(payload, meta)
  business_id = meta["businessId"] || VapiPayload.extract_business_id(payload)
  biz = Business.find(business_id)
  call = payload["call"]

  # Extract lead info
  captured = LeadExtractor.from_function_calls(call["functionCalls"])
  lead = nil
  if captured.present? && (captured["phone"].present? || captured["email"].present?)
    lead = Leads::Upsert.call(
      business: biz,
      lead_source: biz.lead_sources.find_by(slug: "hosted_form") || biz.lead_sources.first,
      attrs: { name: captured["name"], email: captured["email"], phone: captured["phone"], channel: "phone", payload: captured }
    )
  elsif (phone = call["phoneNumber"]).present?
    lead = biz.leads.find_by(phone: LeadNormalizer.normalize(phone: phone)[:phone])
  end

  # Create call log
  record = Call.find_or_initialize_by(vapi_call_id: call["id"])
  if record.new_record?
    record.assign_attributes(
      business_id: biz.id,
      lead_id: lead&.id,
      caller_phone: call["phoneNumber"],
      duration_seconds: call["duration"],
      recording_url: call["recordingUrl"],
      transcript: VapiPayload.compact_transcript(call["transcript"]),
      captured: captured || {},
      intent: IntentClassifier.call(call, nil)
    )
    
    # ⚠️ CRITICAL: Handle race conditions with database constraint
    begin
      record.save!
    rescue ActiveRecord::RecordNotUnique
      # Lost the race, fetch the winner's record
      record = Call.find_by!(vapi_call_id: call["id"])
      record.update!(lead_id: lead.id) if lead && record.lead_id.nil?
    end
  else
    record.update!(lead_id: lead.id) if lead && record.lead_id.nil?
  end

  # Update lead status
  if lead
    if call["functionCalls"]&.any? { _1["name"] == "offer_times" }
      lead.update!(status: "booked", last_contacted_at: Time.current)
    elsif call["functionCalls"]&.any? { _1["name"] == "capture_lead" }
      lead.update!(status: "contacted", last_contacted_at: Time.current)
    else
      lead.update!(status: "contacted")
    end
  end

  # Notify owner on new lead creation
  if lead&.previous_changes&.key?("id")
    SendEmailJob.perform_later(
      to: biz.user.email,
      template: "new-lead",
      data: { lead_name: lead.name, lead_phone: lead.phone, lead_email: lead.email, business_id: biz.id, call_id: record.id }
    )
  end

  # Broadcast to dashboard (calls & leads lists)
  BusinessChannel.broadcast_prepend_to(biz, target: "business_calls", partial: "calls/call",  locals: { call: record })
  BusinessChannel.broadcast_prepend_to(biz, target: "business_leads", partial: "leads/lead", locals: { lead: lead }) if lead
  BusinessChannel.broadcast_replace_to(biz, target: "business_stats", partial: "businesses/stats", locals: { business: biz })
end
```

---

## Dashboard (Leads tab)

### Controller

```ruby
class LeadsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_business

  def index
    @leads = @business.leads.order(updated_at: :desc).page(params[:page])
  end

  def show
    @lead = @business.leads.find(params[:id])
    @calls = @business.calls.where(lead_id: @lead.id).order(created_at: :desc)
  end

  def update
    @lead = @business.leads.find(params[:id])
    @lead.update!(params.permit(:status, :name, :email, :phone))
    head :ok
  end

  private
  def set_business
    @business = current_user.businesses.find(params[:business_id])
  end
end
```

### Views

* `businesses/dashboard` adds a **Leads** section:

  * KPI tiles: Leads (7d), Booked (7d), Avg Speed-to-Ring (derived from webhook timestamps in a later phase or approximated by `first_contacted_at - lead.created_at`)
  * List (`#business_leads`) of newest leads.
* `leads/_lead.html.erb` row with status pill, contact, channel, “View”.
* `leads/show` panel with details + associated calls.

---

## Seed / Setup

* When a Business is created (Phase 3 convert), seed **LeadSource(hosted_form)** with `slug = parameterized(business.name)`, unique within Business.
* Expose the **public URL** on dashboard: `/l/:slug` + sample QR and “Copy link”.

---

## Security & Abuse Controls

* **Hosted form**:

  * Consent checkbox (“I agree to be contacted by phone by {{business}}.”)
  * Throttle per IP (e.g., 5 submissions / 10 min).
  * Optional **hCaptcha** (flag-gated; can stub for MVP).
  * CSRF enabled on POST.
* **Outbound speed-to-lead**:

  * Quiet hours: configurable per Business (default ON); queue job until window if outside.
* **Logs**: Mask emails/phones from logs; don’t log transcript bodies.

---

## Retention

* Reuse **PurgeOldTrialsJob** pattern for `calls` and `leads` if needed:

  * Non-customers: purge after 30 days (configurable).
  * Customers: retain; provide export (Phase 6+).
* Keep only **metadata** after purge (duration, intent counts).

---

## Testing Plan

**Fixtures**

* Vapi paid webhook with `functionCalls`: `capture_lead` and `offer_times`.
* Hosted form submissions with UTM params.

**Model specs**

* `Lead`: validations; unique (business_id, email)/(business_id, phone) partial indexes.
* `LeadSource`: unique slug per business.

**Service specs**

* `LeadNormalizer` normalizes phones.
* `Leads::Upsert` creates or updates properly (email/phone dedupe).
* `IntentClassifier` and `LeadExtractor` already tested; extend with new cases.

**Request specs**

* `GET /l/:slug` renders form.
* `POST /l/:slug` creates/updates lead, enqueues SpeedToLeadJob, redirects to thanks.
* Throttling returns 429 when abused.
* `GET /businesses/:id/leads` requires auth; lists leads.

**Job specs**

* `SpeedToLeadJob` calls Vapi and timestamps lead.
* `ProcessVapiEventJob#process_paid` links calls to leads, updates statuses, broadcasts, idempotent.

**System spec**

* Login → open dashboard → copy hosted URL → submit form (in second session) → see lead appear via Turbo; simulate webhook → see call card linked on lead detail.

Coverage for Phase 5 code: **≥ 85%**.

---

## Tickets (copy into tracker)

1. **P5-01: Migrations — lead_sources, leads, calls.lead_id, businesses.defaults**
   **AC**: schema + FKs + partial unique indexes.
   **Tests**: migration/schema spec.

2. **P5-02: Seed hosted_form LeadSource on conversion**
   **AC**: upon Business creation, create `lead_sources(slug=name-param, name="Hosted Form")`.
   **Tests**: convert job spec extended.

3. **P5-03: Lead normalizer & upsert service**
   **AC**: dedupe by phone/email; preserve payload; sets status=new.
   **Tests**: unit specs.

4. **P5-04: LeadFormsController + views**
   **AC**: public form renders; POST creates/updates lead; thank-you page; consent required.
   **Tests**: request/system specs.

5. **P5-05: SpeedToLeadJob**
   **AC**: triggers Vapi outbound; updates timestamps; retries.
   **Tests**: job spec.

6. **P5-06: Webhook paid linking** (ProcessVapiEventJob)
   **AC**: attach call to lead, update status (contacted/qualified/booked), email notify on new lead.
   **Tests**: job + request specs with fixtures.

7. **P5-07: Dashboard Leads tab** (+ partials)
   **AC**: shows KPI tiles, live list, lead detail with associated calls.
   **Tests**: system spec.

8. **P5-08: Business settings (default_scenario_slug)**
   **AC**: UI to pick scenario; saved to Business; (optional) patch assistant serverUrl.
   **Tests**: request spec.

9. **P5-09: Throttles & hCaptcha (flag)**
   **AC**: rate limit for `/l/:slug`; hCaptcha behind env flag.
   **Tests**: request specs.

10. **P5-10: Emails** (“new lead” template)
    **AC**: send on lead creation; includes call link and recording if available.
    **Tests**: mailer spec.

---

## Non-Functional Targets

* **Speed-to-Ring** from form submit: ≤ 10s (job enqueue→Vapi call) in daytime hours.
* **Idempotency**: multiple webhooks/duplicates do not create duplicate leads or calls.
* **Privacy**: PII not logged; purge policy applied to non-customers.
* **UX**: Hosted form loads fast (< 1s TTFB), clearly states consent, and shows a thank-you state.

---

## Environment

```
# App
APP_URL=https://beakerai.com

# Optional anti-spam
HCAPTCHA_SITE_KEY=...
HCAPTCHA_SECRET=...
```

---

## Phase 5 Exit Criteria

**Product:**
- [ ] Businesses have a public hosted form link `/l/:slug`
- [ ] Submitting the form creates/updates a Lead and immediately triggers a call
- [ ] Lead appears in Dashboard with linked call (via lead_id)
- [ ] Hosted form mobile-optimized (375px); consent checkbox required
- [ ] Default scenario configurable per Business and used by assistant
- [ ] Lead deduplication working (phone/email normalization)

**Metrics/SLOs:**
- [ ] Speed-to-Ring ≤10s (form submit → Vapi call initiated)
- [ ] Lead form TTFB <1s
- [ ] Webhook→dashboard latency <3s for linked call/lead display
- [ ] Quiet hours enforced in RECIPIENT timezone (not business timezone)

**Operations:**
- [ ] Paid webhooks link calls to leads and update statuses correctly
- [ ] Owner email sent on new leads (includes call link and recording when available)
- [ ] Throttles active on hosted form (5 submissions/10min per IP)
- [ ] Consent required and enforced; audit events logged
- [ ] CI green; staging E2E verified

**Risks Mitigated:**
- [ ] TCPA compliance: Recipient timezone quiet hours implemented and tested
- [ ] Lead duplication: Phone/email normalization prevents duplicates
- [ ] Spam: Form throttles and consent enforcement active
- [ ] **Tests (10 total):** Speed-to-lead flow, lead deduplication, quiet hours (recipient timezone), webhook-to-lead linking

---

If you want, I can generate **paste-ready migrations**, the **LeadFormsController**, and the **Leads::Upsert** service with specs so your team can open the Phase 5 PR right away.
Awesome — here's **Phase 4.5: Compliance & Guardrails (RUNS IN PARALLEL WITH PHASE 4)** as a complete, engineer-ready plan.

> ⚠️ **LEGAL REQUIREMENT**: This phase MUST be completed before launching Phase 4 paid features. Outbound calling without these protections creates TCPA liability ($500-$1,500 per violation). Schedule Phase 4.5 work to START when Phase 4 starts.

> ⚠️ Not legal advice. These controls reduce risk and improve trust; you (or counsel) should review TCPA/recording laws, consent language, data retention, and marketing rules for your jurisdictions.

---

# Phase 4.5 — Compliance & Guardrails (RUNS IN PARALLEL WITH PHASE 4)

## Goal (Definition of Done)

⚠️ **LEGAL REQUIREMENT**: This phase MUST be completed before launching Phase 4 paid features. Outbound calling without these protections creates TCPA liability ($500-$1,500 per violation). Schedule Phase 4.5 work to START when Phase 4 starts.

* Outbound calls (trial + paid + speed-to-lead) are **policy-gated** (consent, quiet hours, DNC, velocity, quotas).
* **Consent** is captured and queryable (who consented, when, to what).
* **Recording/PII** handling meets minimum privacy posture (announce recording, redact PII in logs, purge schedules).
* Users can **unsubscribe** email and **opt-out** of calls (DNC) with self-serve endpoints.
* Admin can inspect and override compliance settings, DNC, and audit logs.
* Webhook/auth hardening, throttles, and alerts are in place.
* Comprehensive tests cover the guardrails.

---

## Architecture Overview

* New tables: `compliance_settings`, `consents`, `dnc_numbers`, `audit_logs`.
* Services: `CallPermission`, `PolicyEnforcer`, `ConsentLogger`, `Redactor`.
* Jobs: `DataRetentionJob` (unified purge), `DncSyncJob` (optional for external lists).
* Controllers/Endpoints: email unsubscribe `/u/:token`, DNC web opt-out `/dnc/:token`, admin settings.
* Rack::Attack rules extended (velocity, bursts).
* Logging: PII redaction middleware + structured **audit events** on risky actions.

---

## Data Model (migrations)

### 1) `compliance_settings` (per Business)

```ruby
create_table :compliance_settings, id: :uuid do |t|
  t.uuid   :business_id, null: false, index: { unique: true }
  t.boolean :recording_announce, null: false, default: true
  t.boolean :enforce_quiet_hours, null: false, default: true
  t.integer :quiet_start_hour, null: false, default: 8     # local business hours
  t.integer :quiet_end_hour,   null: false, default: 21
  t.integer :outbound_daily_cap, null: false, default: 50  # speed-to-lead safety
  t.integer :outbound_per_min_cap, null: false, default: 5
  t.boolean :block_international, null: false, default: true
  t.boolean :allow_trial_outbound, null: false, default: true
  t.timestamps
end
add_foreign_key :compliance_settings, :businesses
```

### 2) `consents`

```ruby
create_table :consents, id: :uuid do |t|
  t.uuid    :user_id, index: true
  t.uuid    :business_id, index: true                       # for hosted lead form consents
  t.string  :subject_type                                   # "user" | "lead" | "trial"
  t.uuid    :subject_id                                     # users.id | leads.id | trial_sessions.id
  t.string  :channel, null: false                           # "email" | "phone"
  t.string  :purpose, null: false                           # "marketing" | "call_test" | "speed_to_lead"
  t.boolean :opt_in, null: false, default: true
  t.text    :statement                                      # snapshot of the consent text shown
  t.string  :ip
  t.string  :user_agent
  t.datetime :consented_at, null: false
  t.timestamps
  t.index [:subject_type, :subject_id, :purpose, :channel], name: "idx_consents_subject"
end
add_foreign_key :consents, :users
add_foreign_key :consents, :businesses
```

### 3) `dnc_numbers`

```ruby
create_table :dnc_numbers, id: :uuid do |t|
  t.uuid   :business_id, null: false, index: true
  t.string :phone_e164,  null: false
  t.string :source,      null: false, default: "self"   # self|import|api
  t.datetime :opted_out_at, null: false
  t.timestamps
  t.index [:business_id, :phone_e164], unique: true
end
add_foreign_key :dnc_numbers, :businesses
```

### 4) `audit_logs`

```ruby
create_table :audit_logs, id: :uuid do |t|
  t.uuid    :actor_user_id, index: true         # who did it (optional for webhooks)
  t.string  :actor_type, default: "user"        # user|system|webhook
  t.string  :event, null: false                 # "call_blocked", "unsubscribe", "dnc_add", ...
  t.jsonb   :metadata, null: false, default: {} # reason, phone, business_id, request_id
  t.datetime :created_at, null: false
end
add_foreign_key :audit_logs, :users, column: :actor_user_id
```

*(Phase 2’s retention job can be extended; see below.)*

---

## Services & Enforcement

### `CallPermission` (hard gate before any outbound)

> ⚠️ **TCPA CRITICAL**: Enforcing quiet hours on business timezone instead of recipient timezone is a TCPA violation. Example: NYC business calling LA lead at 8:30 AM EST = 5:30 AM PST = violation. Always derive timezone from phone number's area code. The CallPermission service below uses the timezone-aware QuietHours module from Phase 5.

```ruby
# app/services/call_permission.rb
class CallPermission
  Result = Struct.new(:ok, :reason, keyword_init: true)

  def self.check!(business:, to_e164:, context:)
    res = check(business:, to_e164:, context:)
    raise StandardError, "call blocked: #{res.reason}" unless res.ok
    res
  end

  def self.check(business:, to_e164:, context:)
    s = business.compliance_setting || ComplianceSetting.new

    # 1) DNC
    return deny("dnc_match") if business.dnc_numbers.exists?(phone_e164: to_e164)

    # 2) International if blocked
    if s.block_international && !to_e164.start_with?("+1")
      return deny("international_blocked")
    end

    # 3) Quiet hours
    if s.enforce_quiet_hours && quiet_now?(business, to_e164, s)
      return deny("quiet_hours")
    end

    # 4) Velocity (per minute) – use Redis counter
    if velocity_exceeded?(business.id, s.outbound_per_min_cap)
      return deny("velocity_exceeded")
    end

    # 5) Daily cap
    if daily_cap_exceeded?(business.id, s.outbound_daily_cap)
      return deny("daily_cap_exceeded")
    end

    # 6) Trial outbound ban (if toggled)
    if context[:kind] == "trial" && !s.allow_trial_outbound
      return deny("trial_outbound_disabled")
    end

    allow
  end

  def self.allow = Result.new(ok: true, reason: nil)
  def self.deny(reason) = Result.new(ok: false, reason:)

  def self.quiet_now?(business, to_e164, s)
    # ⚠️ Use recipient's timezone (from area code), not business timezone
    tz = PhoneTimezone.lookup(to_e164) || "America/Chicago"
    hour = Time.current.in_time_zone(tz).hour
    !(hour >= s.quiet_start_hour && hour < s.quiet_end_hour)
  end

  def self.velocity_exceeded?(biz_id, per_min_cap)
    return false if per_min_cap.to_i <= 0
    key = "v:biz:#{biz_id}:m:#{Time.current.strftime('%Y%m%d%H%M')}"
    count = Redis.new(url: ENV["REDIS_URL"]).incr(key)
    Redis.new(url: ENV["REDIS_URL"]).expire(key, 120)
    count > per_min_cap
  end

  def self.daily_cap_exceeded?(biz_id, daily_cap)
    return false if daily_cap.to_i <= 0
    key = "v:biz:#{biz_id}:d:#{Time.current.strftime('%Y%m%d')}"
    count = Redis.new(url: ENV["REDIS_URL"]).incr(key)
    Redis.new(url: ENV["REDIS_URL"]).expire(key, 24.hours.to_i)
    count > daily_cap
  end
end
```

**Integrate into jobs** (Phase 1 & 5):

* `StartTrialCallJob` and `SpeedToLeadJob` must call `CallPermission.check!(business: …, to_e164: phone, context: {kind: "trial"|"lead"})` and **log audit** on deny.

### `ConsentLogger`

```ruby
class ConsentLogger
  def self.log!(subject:, channel:, purpose:, statement:, ip:, ua:, business: nil, user: nil, opted_in: true)
    Consent.create!(
      user_id: user&.id,
      business_id: business&.id,
      subject_type: subject.class.name.underscore,
      subject_id: subject.id,
      channel: channel,
      purpose: purpose,
      opt_in: opted_in,
      statement: statement,
      ip: ip,
      user_agent: ua,
      consented_at: Time.current
    )
  end
end
```

* Use at:

  * **Signup** (Phase 1): marketing consent (`channel:"email", purpose:"marketing"`).
  * **Trial call** (Phase 1): call-test consent (`channel:"phone", purpose:"call_test"`) with the exact checkbox copy.
  * **Hosted form** (Phase 5): speed-to-lead (`channel:"phone", purpose:"speed_to_lead"`).

### `Redactor`

```ruby
class Redactor
  EMAIL_RX = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i
  PHONE_RX = /\+?\d[\d\-\s().]{7,}\d/
  def self.mask(text)
    return text unless text
    text.gsub(EMAIL_RX, "[email]").
         gsub(PHONE_RX, "[phone]")
  end
end
```

* Apply in logger formatters / Lograge custom options to sanitize message params (never print transcripts).

### Audit helper

```ruby
class Audit
  def self.log(event:, actor_user: nil, metadata: {})
    AuditLog.create!(actor_user_id: actor_user&.id, actor_type: actor_user ? "user" : "system",
                     event:, metadata:, created_at: Time.current)
  end
end
```

---

## Recording Announcement (first message)

* Ensure **trial** and **paid** assistants include a recording disclosure when `recording_announce=true`.

* Update `PromptBuilder` (and/or assistant `firstMessage` in Vapi request) to prepend:

  > “This call may be recorded for quality and training purposes.”

* Add a per-Business toggle in **Compliance Settings** to disable (default **on**).

---

## Unsubscribe & DNC Self-Serve

### Email unsubscribe

* Tokenized link in all emails: `/u/:token` with `EmailSubscription` id + HMAC.
* Controller flips `unsubscribed_at` and sets `opt_in=false` for `list`.
* Audit event `unsubscribe`.

### DNC web opt-out (no SMS yet)

* Include a link in emails/hosted form confirmations: `/dnc/:token?phone=+1XXX`.
* Controller validates token (HMAC derived from Business), normalizes phone, upserts `dnc_numbers`.
* Audit event `dnc_add`.

```ruby
class UnsubscribesController < ApplicationController
  def show
    sub = EmailSubscription.find(signed_id_param)
    sub.update!(opt_in: false, unsubscribed_at: Time.current)
    Audit.log(event: "unsubscribe", metadata: {list: sub.list, user_id: sub.user_id})
    render :done
  end
end

class DncController < ApplicationController
  def create
    biz = Business.find(signed_business_param)
    phone = LeadNormalizer.normalize(phone: params[:phone])[:phone]
    return head :bad_request if phone.blank?
    biz.dnc_numbers.find_or_create_by!(phone_e164: phone) { |r| r.opted_out_at = Time.current }
    Audit.log(event: "dnc_add", metadata: {business_id: biz.id, phone: phone})
    render :done
  end
end
```

*(Implement `signed_id_param` helpers with `signed_id` or `ActiveSupport::MessageVerifier`.)*

---

## Data Retention & Purge (unified)

### `DataRetentionJob` (daily)

Rules:

* **Trials (not converted):** redact `trial_calls` transcripts/recordings at **7 days** (already Phase 2).
* **Paid calls:** optionally **keep transcripts**; but allow **redact after N days** if `business.scenario_settings[:retain_transcripts_days]` set.
* **Consents, Audit logs**: keep (legal record).
* **Leads**: keep unless user asks to delete (Phase 6+ will add GDPR/CCPA tooling).

```ruby
class DataRetentionJob < ApplicationJob
  queue_as :low

  def perform
    redact_trials!
    redact_paid_calls_with_policies!
  end

  def redact_trials!
    TrialCall.joins(:trial_session)
      .where("trial_sessions.status != 'converted'")
      .where("trial_calls.created_at < ?", 7.days.ago)
      .find_each { |c| c.update!(transcript: {}, recording_url: nil, captured: {}) }
  end

  def redact_paid_calls_with_policies!
    Business.find_each do |biz|
      days = biz.scenario_settings["retain_transcripts_days"].to_i
      next if days <= 0
      biz.calls.where("created_at < ?", days.days.ago).find_each do |c|
        c.update!(transcript: {}, recording_url: nil)
      end
    end
  end
end
```

---

## Controllers / UI

### Business → **Compliance** tab

* Form for:

  * Recording announcement (checkbox)
  * Quiet hours start/end (select)
  * Block international calls (checkbox)
  * Outbound daily cap & per-minute cap
  * Toggle trial outbound
* Display **DNC list** with add/delete.
* Show most recent **Audit** entries (last 50).

### Integrations

* `StartTrialCallJob` / `SpeedToLeadJob`: call `CallPermission.check!`; on denial:

  * surface friendly message in UI,
  * `Audit.log(event: "call_blocked", metadata: {reason, to, context})`.

---

## Rack::Attack Hardening

Add rules:

* `/l/:slug` POST: 10 requests / 10 minutes / IP
* `/trial/*/call`: 5 requests / 10 minutes / IP
* `/webhooks/*`: allow bursts up to e.g. 120/min per IP; block above 300/min.
* `/stripe/checkout`: 10/min per user id.

Provide **SAFE_LIST** for Twilio/Vapi IPs if necessary or rely on signature tokens.

---

## Webhook & Secrets Hardening

* Rotate `VAPI_WEBHOOK_SECRET` and switch to **HMAC body signature** verification if Vapi supports; otherwise keep random token in query (already added).
* Ensure **Stripe** webhook secret stored in credentials; refuse unsigned requests.
* Ensure **Twilio** console does not point to our app (we point it to Vapi only).

---

## Testing Plan

**Model specs**

* `ComplianceSetting` defaults; bounds for hours and caps.
* `DncNumber` unique constraints; normalization.

**Service specs**

* `CallPermission`: cases for DNC, international, quiet hours, velocity/daily caps, trial flag.
* `ConsentLogger` writes correct row; includes statement snapshot.
* `Redactor.mask` masks emails/phones.

**Job specs**

* `DataRetentionJob` redacts as per rules.
* (Optional) `DncSyncJob` if you add external list import.

**Request specs**

* Compliance settings update (authz).
* `DncController` create adds DNC; blocks duplicate (idempotent).
* `UnsubscribesController` marks unsubscribed.

**Integration specs**

* StartTrialCallJob blocked by quiet hours; UI shows 403 message.
* SpeedToLeadJob blocked by DNC; audit written.

**System specs**

* Business owner navigates to Compliance tab, changes quiet hours; StartTrialCall now blocked until allowed window.

Coverage target for Phase 6 code: **≥85%**.

---

## Tickets (copy into tracker)

1. **P6-01 Migrations**: `compliance_settings`, `consents`, `dnc_numbers`, `audit_logs`.
   **AC**: schema created; indexes & FKs present.
   **Tests**: schema specs.

2. **P6-02 Services**: `CallPermission`, `ConsentLogger`, `Redactor`, `Audit`.
   **AC**: methods behave per spec; PII masked; audit rows inserted.
   **Tests**: unit specs.

3. **P6-03 Integrate enforcement** in `StartTrialCallJob` & `SpeedToLeadJob`.
   **AC**: denies with proper reasons; UI shows friendly message; audit logged.
   **Tests**: job & request specs.

4. **P6-04 Recording announcement** toggle + PromptBuilder / assistant first message update.
   **AC**: when enabled, first message contains disclosure; can be disabled.
   **Tests**: unit test for prompt content.

5. **P6-05 Unsubscribe flow** `/u/:token`.
   **AC**: token verified; subscription marked `unsubscribed_at`; audit row; idempotent.
   **Tests**: request spec.

6. **P6-06 DNC web opt-out** `/dnc/:token`.
   **AC**: phone normalized and stored; subsequent outbound denied; audit row.
   **Tests**: request & service specs.

7. **P6-07 Compliance tab UI** (Business).
   **AC**: update settings; manage DNC entries; list recent audits.
   **Tests**: system spec.

8. **P6-08 Rack::Attack hardening**.
   **AC**: configured thresholds; webhooks allowed; abuse blocked.
   **Tests**: request specs.

9. **P6-09 DataRetentionJob (unified)**.
   **AC**: redacts trial & paid transcripts per policy; idempotent.
   **Tests**: job spec.

10. **P6-10 Webhook verification hardening**.
    **AC**: HMAC/secret verified; bad requests 401/400; log minimal info.
    **Tests**: request specs with invalid signatures.

---

## Non-Functional Targets

* **Zero outbound** to DNC numbers.
* **Outbound velocity** respected (no more than configured caps).
* **PII in logs**: 0 incidents (emails/phones masked).
* **Retention**: transcripts redacted as scheduled (monitor with a daily audit).
* **Mean failure to block** (MFTB): < 1% (false negatives) in enforcement tests.

---

## Environment Variables

```
APP_URL=https://beakerai.com
REDIS_URL=redis://...

VAPI_WEBHOOK_SECRET=...
STRIPE_WEBHOOK_SECRET=...

# HMAC salts for signed links
UNSUBSCRIBE_SALT=...
DNC_SALT=...
```

---

## Phase 4.5 Exit Criteria

**Product:**
- [ ] Outbound calls gated by `CallPermission` service (DNC/quiet-hours/velocity/daily caps)
- [ ] Consent records exist for signup, trial calls, and hosted form submits (with IP/timestamp/statement)
- [ ] Recording disclosure shown when enabled (configurable per Business)
- [ ] Email unsubscribe & DNC opt-out links work; signed tokens verified
- [ ] Admin/owner can manage compliance settings & DNC list via UI

**Metrics/SLOs:**
- [ ] Zero outbound calls to DNC numbers (100% block rate)
- [ ] `call_blocked_quiet_hours` event count >0 daily (proves logic working)
- [ ] Quiet hours enforced in RECIPIENT timezone (area code → timezone lookup)
- [ ] PII in logs: 0 incidents (emails/phones masked via Redactor)
- [ ] Mean failure to block (MFTB) <1% in enforcement tests

**Operations:**
- [ ] PII redaction applied to logs; transcripts redacted per retention schedule
- [ ] DataRetentionJob purges trial/paid transcripts per policy
- [ ] Audit logs created for all blocked calls and compliance changes
- [ ] CI green; staging verified end-to-end

**Risks Mitigated:**
- [ ] TCPA violations: Recipient timezone quiet hours tested, DNC enforced, consent logged
- [ ] Legal exposure: All guardrails operational, audit trail complete
- [ ] Velocity abuse: Per-minute and daily caps enforced via Redis counters
- [ ] **Tests (15 total, <120s):** TCPA quiet hours (RECIPIENT timezone), DNC enforcement, consent logging with IP/timestamp, velocity caps (see Section 12)
- [ ] **Compliance audit suite:** `spec/compliance/tcpa_spec.rb` with all guardrails tested (see Section 12)

---

If you want, I can generate paste-ready migrations, the `CallPermission` service wired into your existing jobs, and the Compliance tab views so your team can ship Phase 4.5 faster.

Awesome — here's **Phase 6: Analytics, Reporting & Admin** as a complete, engineer-ready plan. It assumes Phases 1–5 and 4.5 are live.

---

# Phase 6 — Analytics, Reporting & Admin

## Goal (Definition of Done)

* Owners see **useful KPIs** (calls, leads, booked, speed-to-lead, TTFT, AHT) on the dashboard + trends (7/30d).
* Automatic **Daily Report email** (and optional Weekly) per Business at local morning time.
* **CSV exports** for Calls and Leads.
* Lightweight **Admin** with search/filter, event reprocessing, and feature flags.
* **Backfills** compute history once and incremental metrics stay fresh in near-real-time.
* Tests cover formulas and email/report generation.

---

## High-Level Architecture

* **Read-optimized tables**: `analytics_daily` (per business per day) + `analytics_system_daily` (global).
* **Incremental materialization**: `AnalyticsIngestJob` runs on each call/lead change; `AnalyticsDailyRollupJob` finalizes D-1 at 02:00 business TZ.
* **Reporting**: `DailyReportJob` schedules per business at 08:00 local (uses `business.timezone`).
* **Admin**: `Admin::Dashboard`, `Admin::Events`, `Admin::Trials`, `Admin::Businesses`, `Admin::Flags`.
* **Exports**: signed URL links (ActiveStorage-less; we stream CSV).

---

## Data Model (migrations)

### 1) `businesses` (augment)

```ruby
change_table :businesses do |t|
  t.string  :timezone, null: false, default: "America/Chicago"
end
```

### 2) `calls` (augment analytics hints)

```ruby
change_table :calls do |t|
  t.string  :outcome                         # "booked"|"lead"|"info"|"escalated"|"no_answer"
  t.integer :ttft_ms                         # time to first assistant token/message (approx)
  t.datetime :started_at
  t.datetime :ended_at
end
```

> You can populate `started_at`/`ended_at` from Vapi payload timestamps; if absent, derive from `created_at` + `duration_seconds`.

### 3) `analytics_daily`

Per business/day snapshot.

```ruby
create_table :analytics_daily, id: :uuid do |t|
  t.uuid    :business_id, null: false, index: true
  t.date    :day,         null: false
  t.integer :calls_total, null: false, default: 0
  t.integer :calls_answered, null: false, default: 0    # calls with >= N user turns (e.g., 1+)
  t.integer :leads_new,   null: false, default: 0
  t.integer :booked,      null: false, default: 0
  t.integer :unique_callers, null: false, default: 0
  t.integer :speed_to_lead_ms_p50                     # [POST-LAUNCH] Use average initially
  t.integer :speed_to_lead_ms_p90                     # [POST-LAUNCH] Use average initially
  t.integer :ttft_ms_p50                              # [POST-LAUNCH] Use average initially
  t.integer :aht_s_avg                                # Average Handle Time (secs)
  t.jsonb   :extras, null: false, default: {}         # { intents: {lead_intake: X, ...} }
  t.timestamps
  t.index [:business_id, :day], unique: true
end
add_foreign_key :analytics_daily, :businesses
```

### 4) `analytics_system_daily`

Global snapshot (sales/ops view).

```ruby
create_table :analytics_system_daily, id: :uuid do |t|
  t.date    :day, null: false, index: { unique: true }
  t.integer :signups, null: false, default: 0
  t.integer :trials_started, null: false, default: 0
  t.integer :trial_calls, null: false, default: 0
  t.integer :conversions, null: false, default: 0
  t.integer :mrr_cents, null: false, default: 0
  t.timestamps
end
```

---

## Metric Definitions (deterministic & cheap)

**[MVP] Core Metrics (Counts & Averages Only):**
* **Calls (total/answered)** — `answered` := `calls.duration_seconds >= 10` **or** transcript contains ≥1 `"role":"user"` turn
* **Unique callers** — count distinct `caller_phone` for paid calls that day
* **Leads (new)** — leads created that day (paid only)
* **Booked** — calls with `outcome="booked"` **or** function `offer_times` present **or** lead status changed to `booked` that day
* **AHT (s)** — average `duration_seconds` for answered calls that day

**[POST-LAUNCH] Advanced Metrics (Percentiles):**
* **TTFT p50/p90** — Use average initially; add percentiles when data volume justifies
* **Speed-to-Lead p50/p90** — Use average initially (`first_contacted_at − lead.created_at`)
* **Percentile calculation:** Replace with SQL `percentile_cont()` function when optimizing

> We compute **final** daily metrics in the rollup job and **live counters** by recomputing last 1–2 days on each ingest to keep the dashboard fresh.

---

## Services / Jobs

### `AnalyticsComputer`

Pure PORO that computes per-day metrics given a business and a `day` window.

```ruby
class AnalyticsComputer
  # Computes daily metrics for a business
  # Returns hash with keys: calls_total, calls_answered, leads_new, booked, etc.
  
  def self.for_business_day(business_id:, day:)
    # **[MVP]** Core metrics (counts only):
    # - calls_total: Call.where(business_id:, created_at: day).count
    # - calls_answered: duration_seconds >= 10 OR transcript has user turns
    # - leads_new: Lead.where(business_id:, created_at: day).count
    # - booked: calls.where(outcome: "booked").count
    # - unique_callers: distinct count of caller_phone
    # - aht_s_avg: average(duration_seconds) for answered calls
    #
    # **[POST-LAUNCH]** Advanced metrics (percentiles):
    # - ttft_ms_p50, speed_to_lead_ms_p50/p90: Use averages initially
    # - Replace with SQL percentile_cont() or in-memory calculation when volume justifies
    
    # Implementation: Query Call/Lead tables for date range, compute counts, return hash
    # See Section 11.5 for detailed formula definitions
  end
end
```

### `AnalyticsIngestJob` (near-real-time)

Trigger this whenever a `Call` or `Lead` changes (after_commit hook). It recomputes **today** for the business and upserts into `analytics_daily`.

```ruby
class AnalyticsIngestJob < ApplicationJob
  queue_as :low

  def perform(business_id, day = Date.current)
    snapshot = AnalyticsComputer.for_business_day(business_id:, day:)
    AnalyticsDaily.upsert!(business_id:, day:, **snapshot)
  end
end
```

`AnalyticsDaily.upsert!` is a small ActiveRecord model method using `insert … on conflict … do update`.

### `AnalyticsDailyRollupJob` (02:00 local)

Runs per business at 02:00 in **business.timezone** for **yesterday**. Use `automated scheduler` to enqueue with TZ offset, or a daily job that iterates all businesses and computes per their TZ.

### `DailyReportJob`

At 08:00 local per business:

* Loads yesterday snapshot, plus 7d trend deltas (compute with two queries).
* Renders email (HTML + plaintext) with:

  * Calls: total/answered, AHT, TTFT p50
  * Leads: new, booked, speed-to-lead p50
  * Top 3 transcripts (short preview lines) with links to dashboard
  * CTA buttons (Assign number if missing, Share lead form link, View calls)
* Skips if the business had **no activity** yesterday (optional).

### `SystemAnalyticsRollupJob`

Computes `analytics_system_daily` for the platform: signups, trials started (trial_sessions created), trial calls (trial_calls count), conversions (businesses created that day), MRR (sum active subscriptions × price). Use Stripe to fetch active sub amounts or store price cents in tier mapping.

---

## Controllers / Routes / Views

### Routes

```ruby
resources :businesses, only: [] do
  member do
    get :dashboard       # already exists (Phase 4)
    get :analytics       # new page with charts
    get :export_calls
    get :export_leads
  end
end

namespace :admin do
  root "dashboard#show"
  resources :businesses, only: [:index, :show]
  resources :trials, only: [:index, :show]
  resources :events, only: [:index, :show] do
    post :reprocess, on: :member
  end
  resources :flags, only: [:index, :update]
end
```

### Business Analytics Page (`/businesses/:id/analytics`)

* **[MVP]** 3 tiles row: Calls (7d), Leads (7d), Booked (7d) — counts only
* **[POST-LAUNCH]** Chart area: **Calls per day (30d)**, **Leads per day (30d)**, **TTFT p50 (30d)**, **AHT (30d)** — Start with tiles; add charts when data volume justifies
* **[POST-LAUNCH]** "Export CSV" buttons for calls/leads — Build when requested
* Use **Stimulus + Chart.js** (or light chart lib) fed by a JSON endpoint when implementing charts

**Controller**

```ruby
class BusinessAnalyticsController < ApplicationController
  before_action :authenticate_user!
  def show
    @business = current_user.businesses.find(params[:id])
    @series_30d = AnalyticsDaily.where(business_id: @business.id, day: 30.days.ago.to_date..Date.current)
                                .order(:day)
  end

  # [POST-LAUNCH - Build when requested]
  # Simple copy-paste from dashboard sufficient for first 10 customers
  def export_calls
    business = current_user.businesses.find(params[:id])
    send_enum(CallExporter.new(business).enum, filename: "calls-#{Date.current}.csv")
  end

  # [POST-LAUNCH - Build when requested]
  def export_leads
    business = current_user.businesses.find(params[:id])
    send_enum(LeadExporter.new(business).enum, filename: "leads-#{Date.current}.csv")
  end
end
```

**CSV Exporters** **[POST-LAUNCH]**

```ruby
require "csv"
class CallExporter
  # Streaming CSV export (memory-safe for 100k+ records)
  # Pattern: Use Enumerator with find_in_batches to avoid loading all records into memory
  # Headers: id, created_at, caller_phone, duration_seconds, intent, outcome, recording_url
  # Usage: send_enum(CallExporter.new(business).enum, filename: "calls.csv")
  #
  # Implementation: Similar pattern for LeadExporter
  # See Rails guides for send_enum and streaming responses
end
```

---

## Admin

### AuthZ

* Add `users.role` (enum: `owner`, `admin`), or a separate `admin` boolean. Restrict `/admin/*` to admins.

### Admin Views

* **Dashboard**: totals today/7d, error rates, webhook backlog, Sidekiq queues.
* **Trials**: filter by status, created_at; expire button.
* **Businesses**: search by email/name; view compliance settings; “impersonate” (optional, with Audit).
* **Events**: list `webhook_events` (provider, status). Show payload (redacted). Button “Reprocess” → `ReprocessWebhookEventJob`.
* **Flags**: manage Flipper features per business.

### Reprocess Job

```ruby
class ReprocessWebhookEventJob < ApplicationJob
  def perform(webhook_event_id)
    we = WebhookEvent.find(webhook_event_id)
    we.update!(status: "received")
    case we.provider
    when "vapi"   then ProcessVapiEventJob.perform_later(we.id)
    when "stripe" then ProcessStripeEventJob.perform_later(we.id)
    end
  end
end
```

---

## Emails

### Daily Report Mailer

```ruby
class ReportMailer < ApplicationMailer
  def daily_report(business_id, day)
    @biz = Business.find(business_id)
    @snap = AnalyticsDaily.find_by!(business_id: @biz.id, day: day)
    mail to: @biz.user.email, subject: "Your Beaker AI daily report — #{day.strftime('%a %b %-d')}"
  end
end
```

**Job scheduling**

* Create `ScheduleDailyReportsJob` that runs hourly, finds businesses where local time == 08:00 ±5m (use `tzinfo`) and enqueues `DailyReportJob`.

---

## Classification (optional polish)

Backfill `calls.outcome`:

* If `functionCalls` includes `offer_times` → `booked`
* Else if `capture_lead` present → `lead`
* Else if duration < 10s → `no_answer`
* Else if transcript contains “transfer”/“escalate” → `escalated`
* Else → `info`

Add a rake task/job: `AnalyticsBackfillJob` to set `outcome` and compute `ttft_ms` for existing rows.

---

## Testing Plan

**Model specs**

* `AnalyticsDaily` upsert uniqueness, validations.
* `Business.timezone` default.

**Service specs**

* `AnalyticsComputer.for_business_day`:

  * Fixtures: calls/leads for multiple cases; assert numbers.
  * Percentile calculators handle empty sets.
* Exporters emit CSV headers and rows in batches.

**Job specs**

* `AnalyticsIngestJob` upserts today’s snapshot; idempotent on repeated calls.
* `AnalyticsDailyRollupJob` computes yesterday per TZ.
* `DailyReportJob` sends email with correct KPIs & links.
* `ReprocessWebhookEventJob` resets status and enqueues correct processor.

**Request specs**

* `/businesses/:id/analytics` requires auth/ownership; renders page.
* `/businesses/:id/export_calls` streams CSV; rate-limited (Rack::Attack).
* Admin controllers require admin; reprocess path works.

**System specs**

* Create activity (calls/leads), visit analytics page, charts show data (assert dataset in DOM).
* Simulate local time to 08:00; job sends Daily Report (use ActiveJob test helpers).

Coverage: **≥ 85%** for Phase 6 code.

---

## Tickets (copy into tracker)

1. **P6-01 Migrations**: businesses.timezone, calls analytics columns, analytics_daily, analytics_system_daily.
   **AC**: schema created; unique indexes present.

2. **P6-02 AnalyticsComputer + upsert model helpers** **[MVP: Counts/averages only]**
   **AC**: deterministic outputs for fixtures; core metrics (calls_total, calls_answered, leads_new, booked, aht_s_avg); extras intents map present.
   **Note:** Percentile methods **[POST-LAUNCH]** — Use simple averages initially; add percentiles when optimizing.

3. **P6-03 AnalyticsIngestJob (hooks)**
   **AC**: after_commit on Call/Lead enqueues job; upserts today's snapshot.

4. **P6-04 AnalyticsDailyRollupJob (TZ-aware)**
   **AC**: computes D-1 per business at 02:00 local; idempotent.

5. **P6-05 DailyReportJob + ReportMailer + scheduler**
   **AC**: sends at 08:00 local with correct KPIs/links; skip on no activity (configurable).

6. **P6-06 Analytics page (views + controller)** **[MVP: Tiles only]**
   **AC**: 7-day tiles (counts only); owner-only access; mobile-responsive.
   **Note:** 30-day charts **[POST-LAUNCH]** — Add when data volume justifies.

7. **P6-07 CSV exporters (calls/leads) + throttles** **[POST-LAUNCH]**
   **AC**: Build when customers request; copy-paste from dashboard sufficient initially.
   **Implementation:** streams CSV; handles 100k+ rows; 429 on abuse.

8. **P6-08 Calls outcome & TTFT backfill**
   **AC**: rake/job fills outcome and ttft_ms for historical rows; safe to rerun.

9. **P6-09 Admin area (dashboard, events, trials, businesses, flags)**
   **AC**: role-gated; reprocess events; feature toggles with Flipper.

10. **P6-10 System analytics rollup**
    **AC**: writes platform KPIs daily; includes MRR from Stripe/tier mapping.

11. **P6-11 Stripe usage metering (overage billing)** **[POST-LAUNCH]**
    **AC**: Store `stripe_metered_item_id` in Business; report usage via `Stripe::SubscriptionItem.create_usage_record` on each paid call.
    **Tests**: Job spec with Stripe stub; idempotency via call_id.
    **Note:** Phase 3 MVP uses fixed subscription only; add metering when customers approach caps.

---

## Non-Functional Targets

* Incremental ingest latency: **< 5s** from call/lead change to updated tile.
* 30d analytics page loads **< 500ms** server time (use indexed queries, precomputed snapshots).
* Email send window ±10m around 08:00 local.
* CSV export memory-safe (streaming).

---

## Phase 6 Exit Criteria

**Product:**
- [ ] Analytics dashboard tiles show correct 7-day data (calls, leads, booked counts) **[MVP]**
- [ ] 30-day trend charts **[POST-LAUNCH]** — Start with tiles only; add charts when data volume justifies
- [ ] Daily Report email arrives with accurate KPIs and links at 08:00 local
- [ ] CSV exports **[POST-LAUNCH]** — Build when customers request; copy-paste from dashboard sufficient initially
- [ ] Admin can search businesses/trials/leads, inspect webhook events, and reprocess safely
- [ ] Feature flags (Flipper) accessible via admin for A/B testing

**Metrics/SLOs:**
- [ ] Incremental ingest latency <5s (call/lead change → dashboard tile update)
- [ ] Dashboard page load <500ms with 50 calls (performance budget met)
- [ ] Daily email send window ±10min around 08:00 business local time
- [ ] Analytics accuracy: Spot-check matches SQL queries

**Operations:**
- [ ] `AnalyticsIngestJob` running on after_commit hooks (near-real-time updates)
- [ ] `AnalyticsDailyRollupJob` finalizes yesterday's data at 02:00 local
- [ ] `DailyReportJob` scheduled per business timezone
- [ ] Backfill job completed on staging/prod without incident
- [ ] Admin role enforcement working; unauthorized access blocked
- [ ] CI green; E2E staging verification done

**Risks Mitigated:**
- [ ] Operational overload: Automated reporting and rollups reduce manual work to <2 hrs/week
- [ ] Performance degradation: Dashboard queries optimized, N+1 prevented (Bullet clean)
- [ ] Data inaccuracy: Analytics formulas tested, spot-checks passing
- [ ] **Note:** Advanced analytics (percentiles, cohort curves, segment breakdowns) marked **[POST-LAUNCH]** — Use simple averages/counts initially

---

If you want, I can generate paste-ready migrations, the `AnalyticsComputer` class, upsert helpers, and a minimal Analytics page (ERB + Stimulus + Chart.js) so your team can open the Phase 6 PR today.

---

## Document Improvements & Handoff Enhancements (Oct 25, 2025)

This document has been refined through multiple analysis cycles to create a world-class engineering handoff. Key improvements:

### 1. **Strategic Layering (New: Build Strategy Section)**
- **3-Stage Build Summary** added after Executive Summary for high-level planning
- Stage 1: Validate & Ship Trial (Phases 0-2, 4-6 weeks)
- Stage 2: Monetize & Comply (Phases 3-4.5, 4-6 weeks)
- Stage 3: Scale & Automate (Phases 5-6, 4-6 weeks)
- Each stage has clear goals, exit criteria, and risk mitigations

### 2. **Priority Markers Throughout**
- **[MVP]** — Critical path features for first 10 customers
- **[POST-LAUNCH]** — Build after 10-50 customers or when requested
- **[PHASE 7+]** — Deferred to post-MVP expansion
- Applied to: Pricing tiers, add-ons, scenario templates, analytics features, CSV exports

### 3. **Tripwire Alert Configuration (New: Section 8.7)**
- Added 11 critical alerts with thresholds and severities
- Sentry configuration examples for race condition detection
- Monitoring dashboard widget recommendations
- Linked to incident response runbooks (RB-01 to RB-05)

### 4. **Standardized Exit Criteria (All Phases)**
- All phase exit checklists reformatted with 4 sections:
  - Product (features shipped)
  - Metrics/SLOs (performance targets)
  - Operations (monitoring/tooling ready)
  - Risks Mitigated (specific tripwires verified)
- Mobile-first requirements emphasized in every UI phase

### 5. **Simplified Analytics Scope (Phase 6)**
- Core metrics: Counts and averages only for MVP
- Percentile calculations marked **[POST-LAUNCH]**
- Chart implementations deferred (start with tiles only)
- CSV exports deferred (copy-paste sufficient initially)
- Reduced complexity by ~60% while keeping observability

### 6. **Enhanced Mini-Report Emphasis (Phase 2)**
- Upgraded from "critical" to "⚠️ CRITICAL — Mini-Report as Conversion Driver"
- Added mobile-specific requirements (≥60px tap target, fields above fold)
- Explicit prioritization guidance: "Prioritize mini-report perfection over all other Phase 2 UI work"
- Reinforces this is the emotional "aha moment" driving 80% of conversions

### 7. **Deferred Stripe Usage Metering (Phase 3→6)**
- Phase 3 simplified to fixed subscriptions only
- Usage metering moved to Phase 6 ticket P6-11
- Reduces Phase 3 complexity and time-to-market
- Add when customers approach included call caps

### 8. **Consolidated Backlog (Section 13.5)**
- Renamed "Explicitly Deferred" to "Phase 7+ Backlog"
- Consolidated all **[PHASE 7+]** and **[POST-LAUNCH]** items in one place
- Clear rationale: Focus engineering on trial conversion and first 10 customers
- Organized into Phase 7+ vs. Post-Launch (10-50 customers) tiers

### 9. **North Star Metric Progression (Executive Summary)**
- Clarified metric focus shifts over time:
  - Months 0-3: Trial→Paid Conversion (>15%)
  - Months 3-6: Week 1 Success Rate (>40%)
  - Months 6+: Weekly Active Businesses (retention)
- Prevents premature optimization on wrong metrics

### 10. **Reduced Scenario Template Scope**
- Seed 1 template only: HVAC + lead_intake (from 9 templates)
- Gym/dental marked **[POST-LAUNCH]** — clone after HVAC validation
- Updated P1-02 ticket acceptance criteria
- Aligns with single-ICP validation strategy

### What Was Intentionally Excluded

The following recommendations were **not** added to preserve focus:
- **40+ event taxonomy** — Over-engineered; 10 core events sufficient
- **Advanced cohort retention curves** — Premature for <100 customers
- **Complex A/B experiment lifecycle** — Use simple Flipper flags
- **Multiple scenario templates upfront** — Validate HVAC first
- **Detailed CSV export implementations** — Build when requested

### How to Use This Document

**For Product/Founders:**
- Start with Build Strategy (3 stages) for timeline and resource planning
- Reference Key Metrics and North Star Progression for success criteria
- Use Phase 7+ Backlog to manage customer feature requests

**For Engineers:**
- Build Strategy provides sprint/milestone targets
- Priority markers guide scope decisions during implementation
- Detailed phases (Sections 9+) provide tickets, code patterns, and tests
- Exit Criteria ensure quality gates before phase completion
- Keep critical code patterns (webhooks, race conditions, TCPA); simplify others

**For Operations:**
- Section 8.7 (Tripwire Alerts) is pre-launch checklist for monitoring
- Section 8.6 (Runbooks) provides incident response procedures
- Weekly Ops Cadence targets <2 hours/week via automation

### Key Principle

**Ship the mini-report perfectly, get 10 paying HVAC customers, then decide what to build next based on their requests—not the spec.**

