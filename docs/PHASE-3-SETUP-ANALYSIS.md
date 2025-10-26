# Phase 3 Setup Analysis

**Date:** January 26, 2025  
**Status:** Ready to Begin  
**Total Tickets:** 12 tickets, ~36 points

## Current Status Review

### ✅ What's Already Setup

#### 1. Business Model
- ✅ **Business model exists** (`app/models/business.rb`)
- ✅ **BusinessOwnership join table** exists
- ✅ Database migrations complete
- ✅ Associations: User → Business (through BusinessOwnership)

**Note:** Business model exists from Phase 0, but we need to verify it has all Phase 3 fields

#### 2. Webhook Infrastructure
- ✅ **WebhooksController** exists with signature verification
- ✅ **WebhookEvent model** with idempotency (provider + event_id)
- ✅ Route configured: `POST /webhooks/:provider`
- ✅ **WebhookProcessorJob** exists (needs Phase 3 routing)

#### 3. Services & Clients
- ✅ **VapiClient** with circuit breaker
- ✅ **ApiClientBase** with retry logic
- ✅ **TwilioClient** exists (from Phase 1)
- ⚠️ **StripeClient** needs to be created/verified

#### 4. Environment Variables
- ✅ Stripe ENV vars in `env.example`:
  - `STRIPE_SECRET_KEY`
  - `STRIPE_WEBHOOK_SECRET`
  - `STRIPE_SUCCESS_URL`
  - `STRIPE_CANCEL_URL`

---

## ❌ What's Missing for Phase 3

### Critical Gaps

#### 1. **StripeClient Service**
**Status:** NEEDS IMPLEMENTATION  
**Ticket:** R2-E04-T001

**What's Needed:**
- Create `app/services/stripe_client.rb`
- Extend `ApiClientBase` for circuit breaker
- Methods:
  - `create_checkout_session(params)`
  - `retrieve_customer(id:)`
  - `retrieve_subscription(id:)`
  - `construct_event(payload:, sig:)` (webhook verification)
- Idempotency keys for mutating calls

**Check Current State:**
```bash
# Does StripeClient exist?
ls app/services/stripe_client.rb
```

**Reference:** `docs/ticket-details.md` lines 1198-1237

#### 2. **Stripe Products/Prices Configuration**
**Status:** NEEDS CREATION  
**Ticket:** R2-E04-T002

**What's Needed:**
- Create Stripe products/prices in Stripe Dashboard:
  - **Starter Plan:** $199/mo (100 calls)
  - **Pro Plan:** $499/mo (300 calls) - updated pricing from README
- Store price IDs in ENV or database
- Configure plan limits

**Note:** README shows pricing was adjusted to protect margins (300 calls for Pro instead of 500)

#### 3. **Checkout Session Controller**
**Status:** NEEDS IMPLEMENTATION  
**Ticket:** R2-E04-T003

**What's Needed:**
- Create `app/controllers/checkout_controller.rb`
- Route: `POST /checkout/sessions`
- Requires authentication
- Builds idempotency key: `checkout:<user_id>:<trial_session_id>`
- Redirects to Stripe Checkout

**Reference:** `docs/ticket-details.md` lines 1241-1268

#### 4. **Stripe Webhook Handler**
**Status:** NEEDS IMPLEMENTATION  
**Ticket:** R2-E04-T004

**What's Needed:**
- Update `WebhooksController` to handle Stripe events
- Verify signature using `StripeClient.construct_event`
- Handle `checkout.session.completed` event
- Enqueue `ConvertTrialToBusinessJob`
- Idempotency via existing `WebhookEvent` model

**Reference:** `docs/ticket-details.md` lines 1272-1304

#### 5. **ConvertTrialToBusinessJob**
**Status:** NEEDS IMPLEMENTATION  
**Ticket:** R2-E04-T005 (5 points)

**What's Needed:**
- Create `app/jobs/convert_trial_to_business_job.rb`
- Inputs: `user_id`, `trial_session_id`, `stripe_session_id`
- Steps:
  1. Idempotency: upsert `ProvisioningRun` keyed by `stripe_session_id`
  2. Create `Business` record
  3. Clone Vapi assistant (from Trial)
  4. Link Business to assistant_id, stripe_customer_id, stripe_subscription_id
  5. Mark trial as "converted"
  6. Send "Agent Ready" email

**Reference:** `docs/ticket-details.md` lines 1308-1346

#### 6. **Business Model Verification**
**Status:** ✅ ALREADY EXISTS  
**Ticket:** R2-E04-T006

**Fields Verified:**
- ✅ `stripe_customer_id` (string, unique index)
- ✅ `stripe_subscription_id` (string, index)
- ✅ `plan` (enum: starter, pro)
- ✅ `status` (enum: active, past_due, canceled)
- ✅ `calls_included` (integer, default: 100 for starter, 500 for pro)
- ✅ `calls_used_this_period` (integer, default: 0)
- ✅ `vapi_assistant_id` (string, index)

**Note:** Business model and migration already exist from Phase 0. Pro plan has 500 calls_included (line 29 in model), but README says 300. Need to update to 300 to protect margins.

#### 7. **Assistant Cloning Logic**
**Status:** NEEDS IMPLEMENTATION  
**Ticket:** R2-E04-T007

**What's Needed:**
- Service to clone trial assistant to paid assistant
- Copy scenario template/persona
- Remove time caps (paid assistants have no duration limits)
- Return new `vapi_assistant_id`

#### 8. **Onboarding Page**
**Status:** NEEDS IMPLEMENTATION  
**Ticket:** R2-E04-T008

**What's Needed:**
- Create `app/controllers/onboarding_controller.rb`
- Route: `GET /onboarding/ready?session_id=cs_...`
- Polling endpoint: `/api/onboarding/status?session_id=`
- States: pending, ready, failed
- Redirects to business setup on success

**Reference:** `docs/ticket-details.md` lines 1384-1413

#### 9. **Agent Ready Email**
**Status:** NEEDS IMPLEMENTATION  
**Ticket:** R2-E04-T009

**What's Needed:**
- Create `app/mailers/business_mailer.rb`
- Method: `#agent_ready(user, business)`
- Template: welcome, setup links, deep links
- Triggered by `ConvertTrialToBusinessJob` on success

**Reference:** `docs/ticket-details.md` lines 1445-1473

#### 10. **Idempotency Testing**
**Status:** NEEDS IMPLEMENTATION  
**Ticket:** R2-E04-T010

**What's Needed:**
- Concurrency tests for Stripe webhook processing
- Simulate multiple `checkout.session.completed` events
- Ensure only one Business created
- Ensure only one assistant cloned

**Reference:** `docs/ticket-details.md` lines 1417-1442

#### 11. **Upgrade CTA in Trial UI**
**Status:** NEEDS IMPLEMENTATION  
**Ticket:** R2-E04-T011

**What's Needed:**
- Add upgrade button to trial mini-report
- Link to `/checkout/new?trial_id=:id`
- Track clicks for analytics

#### 12. **Stripe Tax Configuration**
**Status:** ✅ COMPLETED  
**Ticket:** R2-E04-T012

**What Was Done:**
- Added `automatic_tax: { enabled: true }` to all checkout sessions in StripeClient
- Enabled by default (no environment variable toggle needed)
- Comprehensive test coverage at service and integration levels
- Completion doc created with Stripe Dashboard setup instructions

---

## Environment Setup Checklist

### Stripe Configuration

#### 1. Get Stripe API Keys
```bash
# Test keys (development)
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

#### 2. Create Stripe Products (Dashboard)
- Go to Stripe Dashboard → Products
- Create product: "Beaker AI - Starter"
  - Price: $199/month (recurring)
  - Plan limits: 100 calls/month
  - Store price ID: `price_starter_monthly`
- Create product: "Beaker AI - Pro"
  - Price: $499/month (recurring)
  - Plan limits: 300 calls/month
  - Store price ID: `price_pro_monthly`

#### 3. Configure Webhook Endpoint
- Stripe Dashboard → Developers → Webhooks
- Add endpoint: `https://your-app.com/webhooks/stripe`
- Events to subscribe:
  - `checkout.session.completed`
  - `customer.subscription.created`
  - `customer.subscription.updated`
  - `customer.subscription.deleted`
- Copy webhook secret to ENV

#### 4. Enable Stripe Tax (Optional)
- Stripe Dashboard → Tax
- Enable automatic tax calculation
- Configure for US states

### Local Testing Setup

#### 1. Install Stripe CLI (Optional)
```bash
brew install stripe/stripe-cli/stripe
stripe login

# Forward webhooks to local dev
stripe listen --forward-to localhost:3000/webhooks/stripe

# In another terminal
stripe trigger checkout.session.completed
```

#### 2. Test Checkout Flow
1. Use test card: `4242 4242 4242 4242`
2. Any future expiry date
3. Any CVC
4. Any ZIP

---

## Implementation Order

### Sprint 1: Stripe Setup (7 pts)
**Goal:** Get Stripe integration working

1. **R2-E04-T001** (2 pts) - Create StripeClient
2. **R2-E04-T002** (2 pts) - Create products/prices in Stripe Dashboard
3. **R2-E04-T003** (3 pts) - Checkout session controller

**Dependencies:** None - this is foundational

### Sprint 2: Conversion Flow (9 pts)
**Goal:** Convert trials to businesses

4. **R2-E04-T004** (4 pts) - Stripe webhook handler
5. **R2-E04-T006** (3 pts) - Verify Business model fields
6. **R2-E04-T011** (2 pts) - Upgrade button in trial UI

**Dependencies:** Sprint 1 complete

### Sprint 3: Business Provisioning (11 pts)
**Goal:** Create business accounts with assistants

7. **R2-E04-T005** (5 pts) - ConvertTrialToBusinessJob
8. **R2-E04-T007** (4 pts) - Clone assistant logic
9. **R2-E04-T009** (2 pts) - "Agent Ready" email

**Dependencies:** Sprint 2 complete

### Sprint 4: Polish & Testing (9 pts)
**Goal:** Complete onboarding and test idempotency

10. **R2-E04-T008** (2 pts) - Onboarding page
11. **R2-E04-T010** (3 pts) - Idempotency testing
12. **R2-E04-T012** (2 pts) - Stripe Tax configuration

**Dependencies:** Sprint 3 complete

---

## Key Implementation Files

### Services to Create
- `app/services/stripe_client.rb` - Stripe API wrapper with circuit breaker
- (Assistant cloning service - TBD as separate service or part of ConvertTrialToBusinessJob)

### Controllers to Create
- `app/controllers/checkout_controller.rb` - Stripe checkout initiation
- `app/controllers/onboarding_controller.rb` - Post-purchase onboarding

### Jobs to Create
- `app/jobs/convert_trial_to_business_job.rb` - Core conversion logic

### Mailers to Create
- `app/mailers/business_mailer.rb` - Welcome/provisioning emails

### Migrations (if needed)
- Verify `businesses` table has:
  - `stripe_customer_id` (unique index)
  - `stripe_subscription_id`
  - `plan` enum field
  - `status` enum field
  - `calls_included` integer
  - `calls_used_this_period` integer

---

## Testing Strategy

### Unit Tests
- `spec/services/stripe_client_spec.rb` - Circuit breaker, idempotency
- `spec/jobs/convert_trial_to_business_job_spec.rb` - Job logic, idempotency
- `spec/models/business_spec.rb` - Validations, associations

### Integration Tests
- `spec/requests/checkout_spec.rb` - Checkout session creation
- `spec/requests/webhooks/stripe_spec.rb` - Webhook processing
- `spec/requests/onboarding_spec.rb` - Onboarding flow

### End-to-End Tests
- `spec/system/stripe_conversion_spec.rb` - Full trial → business flow

### Manual Testing
```bash
# Use Stripe test mode
stripe listen --forward-to localhost:3000/webhooks/stripe

# Trigger test checkout
stripe trigger checkout.session.completed
```

---

## Dependencies from Phase 2

All Phase 2 infrastructure is complete and ready:
- ✅ Webhook infrastructure (WebhookEvent model, signature verification)
- ✅ Trial model with vapi_assistant_id
- ✅ Call model with polymorphic callable
- ✅ User model with business_ownerships
- ✅ Race condition prevention (unique constraints)

---

## Risk Assessment

### High Risk
1. **Stripe webhook processing race conditions**
   - Mitigation: Use existing idempotency pattern (WebhookEvent + unique constraint)
   - Test with concurrent requests

2. **Assistant cloning failures**
   - Mitigation: Transactional rollback, compensation logic
   - Test Vapi clone failures

### Medium Risk
1. **Checkout session creation idempotency**
   - Mitigation: Idempotency key from user_id + trial_id
   - Test duplicate requests

2. **Trial state transitions**
   - Mitigation: Guard clauses in ConvertTrialToBusinessJob
   - Test already converted trials

### Low Risk
1. **Email delivery failures**
   - Mitigation: Background job with retries
   - Test mailer rendering

---

## Success Metrics

### Phase 3 Exit Criteria (from README)
- ✅ Trial → Upgrade → Stripe Checkout → Business created
- ✅ Paid assistant created (no time caps)
- ✅ Trial marked "converted"
- ✅ No duplicate businesses on webhook retry
- ✅ Conversion latency ≤5s

### Key Performance Indicators
- **Conversion Rate:** Track trial → business conversion %
- **Provisioning Time:** p95 latency for ConvertTrialToBusinessJob
- **Webhook Success Rate:** >99.9% successful webhook processing
- **Checkout Completion:** Track checkout abandonment

---

## Next Steps

1. ✅ Verify Business model has all Phase 3 fields
2. ⏭️ Create StripeClient service (R2-E04-T001)
3. ⏭️ Set up Stripe Dashboard products/prices
4. ⏭️ Implement checkout flow
5. ⏭️ Implement webhook processing
6. ⏭️ Build business provisioning

---

**Analysis Completed:** Ready to start Phase 3 implementation  
**Risk Level:** Low-Medium - Infrastructure is solid, Stripe integration is standard  
**Estimated Velocity:** 9-10 points per sprint (4 sprints total)

