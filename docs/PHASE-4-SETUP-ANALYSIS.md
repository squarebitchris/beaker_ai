# Phase 4 Setup Analysis

**Date:** January 26, 2025  
**Status:** Ready to Begin  
**Total Tickets:** 14 tickets, ~49 points  
**Sprint Breakdown:** 3-4 sprints (admin first, then paid features)

---

## Current Status Review

### ✅ What's Already Setup

#### 1. Business Model (Phase 3 Complete)
- ✅ **Business model exists** (`app/models/business.rb`)
- ✅ **BusinessOwnership join table** exists
- ✅ Stripe integration complete (automatic tax enabled)
- ✅ Trial → Business conversion working
- ✅ All Phase 3 infrastructure complete

#### 2. Webhook Infrastructure (Phase 2 Complete)
- ✅ **WebhooksController** exists with signature verification
- ✅ **WebhookEvent model** with idempotency (provider + event_id)
- ✅ Route configured: `POST /webhooks/vapi`, `POST /webhooks/stripe`
- ✅ **WebhookProcessorJob** exists (needs Phase 4 extension)
- ✅ Vapi webhook processing for trials working

#### 3. Services & Clients
- ✅ **VapiClient** with circuit breaker
- ✅ **TwilioClient** with circuit breaker (from Phase 1)
- ✅ **StripeClient** with automatic tax (Phase 3)
- ✅ **ApiClientBase** with retry logic
- ✅ **ConvertTrialToBusinessJob** working

#### 4. ActionCable & Real-Time
- ✅ **TrialSessionChannel** exists for trial mini-reports
- ✅ Turbo Streams infrastructure operational
- ⚠️ **BusinessChannel** needs to be created

#### 5. Environment Variables
- ✅ Twilio ENV vars configured:
  - `TWILIO_ACCOUNT_SID`
  - `TWILIO_AUTH_TOKEN`
  - `TWILIO_STATUS_CALLBACK_URL`
- ✅ Vapi ENV vars configured
- ✅ Stripe ENV vars configured

---

## ❌ What's Missing for Phase 4

### CRITICAL: Admin Panel Ships FIRST (Sprint 14)

**Priority Order:**
1. **Admin Panel** (Tickets 1-3) - MUST ship before paid features
2. **Twilio Integration** (Tickets 4-5) - Paid product foundation
3. **Dashboard & Live Features** (Tickets 6-14) - User-facing

#### 1. **Admin Panel - Base Interface**
**Status:** NEEDS IMPLEMENTATION  
**Ticket:** R2-E05-T001  
**Priority:** P0 - CRITICAL (ships first)

**What's Needed:**
- Create admin authentication check
- Admin base controller (`app/controllers/admin/base_controller.rb`)
- Admin layout (`app/views/layouts/admin.html.erb`)
- Admin routes namespace
- Admin navigation/menu

**Key Requirements:**
- Admin auth via `user.admin?` boolean flag (already in User model)
- Only admin users can access `/admin/*` routes
- Base layout with sidebar navigation
- Links to webhook inspector, entity search, Sidekiq UI

**Check Current State:**
```bash
# Does admin infrastructure exist?
ls app/controllers/admin/
ls app/views/layouts/admin.*
```

**Reference:** `docs/ticket-details.md` lines 1477-1512

#### 2. **Admin: Webhook Event Inspector**
**Status:** NEEDS IMPLEMENTATION  
**Ticket:** R2-E05-T002  
**Priority:** P0 - Critical for debugging

**What's Needed:**
- Controller: `app/controllers/admin/webhook_events_controller.rb`
- Views: `app/views/admin/webhook_events/index.html.erb`, `show.html.erb`
- Features:
  - List webhook events by provider, status, date
  - Search/filter by event_id, provider, status
  - View raw JSON payload (pretty-printed)
  - Mask PII (phones, emails) in display
  - Show processing status and job info
- Pagination (kaminari or similar)

**UI Requirements:**
- Syntax-highlighted JSON viewer for payloads
- Filter by provider (Stripe, Vapi, Twilio)
- Filter by status (pending, processing, completed, failed)
- Search by event_id
- PII masking (emails: `j***@example.com`, phones: `***-***-1234`)

**Tests Required:**
- Request specs: admin-only access enforced
- Non-admin gets 403/404
- JSON viewer renders correctly
- PII masking works
- Pagination works

**Reference:** `docs/ticket-details.md` lines 1523-1582

#### 3. **Admin: Entity Search**
**Status:** NEEDS IMPLEMENTATION  
**Ticket:** R2-E05-T003  
**Priority:** P0

**What's Needed:**
- Controller: `app/controllers/admin/search_controller.rb`
- Search Businesses, Users, Leads by:
  - Email (case-insensitive, normalized)
  - Phone E.164 (normalized)
  - Business name
  - User ID / UUID
- Autocomplete in admin topbar (Stimulus controller)
- Results show key fields with quick links
- PII masking in results

**Implementation:**
```ruby
# app/controllers/admin/search_controller.rb
def show
  query = params[:q]
  @results = {
    businesses: Business.search(query),
    users: User.search(query),
    leads: Lead.search(query)
  }
end
```

**Tests Required:**
- Search accuracy with normalized emails/phones
- Autocomplete debouncing (Stimulus)
- PII masking in results
- No N+1 queries (Bullet)

**Reference:** `docs/ticket-details.md` lines 1639-1683

#### 4. **Twilio Client Setup + Number Provisioning**
**Status:** PARTIAL - Client exists, provisioning logic needed  
**Ticket:** R2-E05-T004

**What's Needed:**
- Verify `TwilioClient` has `buy_local_number(area_code:)` method
- Verify `TwilioClient` has `update_number_webhook(sid:, voice_url:)` method
- Add phone number purchasing logic
- Circuit breaker integration (already exists)

**Check Current State:**
```bash
# Review existing TwilioClient
grep -A 20 "def buy_local_number" app/services/twilio_client.rb
grep -A 10 "def update_number_webhook" app/services/twilio_client.rb
```

**Additional Methods Needed:**
- `provision_number(area_code: nil)` - Buy and configure number
- `configure_voice_webhook(number_sid:)` - Set voice URL

**Reference:** `docs/ticket-details.md` lines 1686-1735

#### 5. **AssignTwilioNumberJob**
**Status:** NEEDS IMPLEMENTATION  
**Ticket:** R2-E05-T005

**What's Needed:**
- Job: `app/jobs/assign_twilio_number_job.rb`
- Purchase Twilio number via `TwilioClient`
- Configure voice webhook URL
- Update `Business.phone_number_id` association
- Broadcast to `BusinessChannel` on success
- Idempotent: if business already has number, no-op

**Workflow:**
1. Load business with lock
2. Check if `phone_number_id` already exists → exit if yes
3. Call `TwilioClient.buy_local_number(area_code:)`
4. Call `TwilioClient.update_number_webhook(sid:, voice_url:)`
5. Create `PhoneNumber` record
6. Update `Business.phone_number_id`
7. Broadcast to `BusinessChannel`
8. Send "Number Assigned" email

**Tests Required:**
- Job spec with VCR cassettes
- Idempotency test (run twice → one number)
- Error handling (Twilio failures)
- Broadcast verification

**Reference:** `docs/ticket-details.md` lines 1738-1782

#### 6. **Call Model for Paid Calls**
**Status:** NEEDS IMPLEMENTATION  
**Ticket:** R2-E05-T006

**What's Needed:**
- Migration: `create_calls` (if not already exists from Phase 2)
- Model: `app/models/call.rb`
- Fields:
  - `business_id:uuid` (FK)
  - `lead_id:uuid` (FK, nullable for non-lead calls)
  - `direction:string` (inbound, outbound)
  - `status:string` (initiated, ringing, in_progress, completed, failed)
  - `to_e164:string` (recipient phone)
  - `from_e164:string` (originator phone)
  - `vapi_call_id:string` (unique index)
  - `twilio_call_sid:string` (unique index)
  - `duration_seconds:integer`
  - `transcript:text`
  - `recording_url:text`
  - `extracted_lead:jsonb`
  - `intent:string`
  - `meta:jsonb`
  - Timestamps: `started_at`, `ended_at`, `created_at`, `updated_at`
- Associations:
  - `belongs_to :business`
  - `belongs_to :lead, optional: true`
- Indexes:
  - Unique on `vapi_call_id` (where not null)
  - Unique on `twilio_call_sid` (where not null)
  - B-tree on `(business_id, created_at DESC)`
  - B-tree on `status`

**Check Current State:**
```bash
# Does Call model exist?
ls app/models/call.rb
grep "create_calls" db/migrate/*
```

**Note:** May already exist from Phase 2 trial calls. Check if it has business_id association.

**Reference:** Ticket breakdown and database schema

#### 7. **Paid Webhook Processing**
**Status:** NEEDS IMPLEMENTATION  
**Ticket:** R2-E05-T007

**What's Needed:**
- Extend `ProcessVapiEventJob` to handle paid calls
- Add `process_paid(event)` method
- Create/update `Call` record for business
- Handle idempotency via `vapi_call_id` unique constraint
- Broadcast to `BusinessChannel` on status changes
- Link calls to leads when applicable

**Changes to Existing Code:**
```ruby
# app/jobs/process_vapi_event_job.rb
def process_paid(event)
  business = Business.find_by!(vapi_assistant_id: event['assistant_id'])
  call = Call.find_or_initialize_by(vapi_call_id: event['call_id'])
  
  call.update!(
    business: business,
    lead_id: find_lead_by_phone(event['to_e164']),
    direction: event['direction'],
    status: map_vapi_status(event['status']),
    transcript: event['transcript'],
    recording_url: event['recording_url']
  )
  
  broadcast_call_update(call)
end
```

**Reference:** `docs/ticket-details.md` lines 1872-1914

#### 8. **BusinessChannel for Real-Time Updates**
**Status:** NEEDS IMPLEMENTATION  
**Ticket:** R2-E05-T008

**What's Needed:**
- Channel: `app/channels/business_channel.rb`
- Subscribe to per-business updates
- Authorization: only business owners can subscribe
- Broadcast helpers in jobs/controllers

**Implementation:**
```ruby
# app/channels/business_channel.rb
class BusinessChannel < ApplicationCable::Channel
  def subscribed
    business = Business.find(params[:id])
    
    unless current_user.owns?(business)
      reject
      return
    end
    
    stream_for business
  end
end
```

**Broadcast Triggers:**
- New call created (from webhook processor)
- Number assigned (from AssignTwilioNumberJob)
- Call status updated (from webhook processor)

**Reference:** `docs/ticket-details.md` lines 1830-1868

#### 9. **Dashboard UI: Number Display, KPI Tiles, Calls List**
**Status:** NEEDS IMPLEMENTATION  
**Ticket:** R2-E05-T009

**What's Needed:**
- Controller: `app/controllers/businesses_controller.rb` (add dashboard action)
- View: `app/views/businesses/dashboard.html.erb`
- Components:
  - PhoneNumber display (or "Assign Number" CTA)
  - KPI tiles (7-day summary):
    - Calls this week
    - Leads this week
    - Booked appointments
    - Average call duration
  - Recent calls table
  - Empty state (no number assigned)
- Subscribe to `BusinessChannel` for live updates

**KPI Data Sources:**
- Calculate from `Call` records
- Use scopes: `Call.where(business_id:, created_at: 7.days.ago..)`
- Cache/optimize if needed

**Reference:** `docs/ticket-details.md` lines 1785-1827

#### 10. **Usage Alerts (80%, 100% of quota)**
**Status:** NEEDS IMPLEMENTATION  
**Ticket:** R2-E05-T010

**What's Needed:**
- Track calls used vs. calls included
- Show alert in dashboard when approaching limits
- Display current usage percentage
- Warn at 80%: "You've used X of Y calls this month"
- Warn at 100%: "You've reached your monthly call limit"

**Implementation:**
```ruby
# app/models/business.rb
def calls_usage_percentage
  return 0 if calls_included.zero?
  (calls_used_this_period.to_f / calls_included * 100).round
end

def usage_alert_level
  return :ok if calls_usage_percentage < 80
  return :warning if calls_usage_percentage < 100
  :critical
end
```

**UI:**
- Display in dashboard header
- Color-coded progress bar
- Link to upgrade plan

**Reference:** Ticket requirements

#### 11. **Empty States (no calls, no number)**
**Status:** NEEDS IMPLEMENTATION  
**Ticket:** R2-E05-T011

**What's Needed:**
- View partials for empty states
- "Assign Your First Number" CTA when no number
- "No Calls Yet" message when number exists but no calls
- Helpful guidance text
- Mobile-friendly

**Reference:** UX best practices

#### 12. **Mobile-Responsive Dashboard (375px tested)**
**Status:** NEEDS IMPLEMENTATION  
**Ticket:** R2-E05-T012

**What's Needed:**
- Dashboard works at 375px width
- Touch targets ≥44px (60px for primary actions)
- Stack layout vertically on mobile
- KPI tiles stack in single column
- Calls list truncated with "View All" link
- Test with real mobile devices or responsive mode

**Testing:**
- Chrome DevTools mobile emulation
- Physical devices (iPhone SE/Android)
- Lighthouse mobile audit

**Reference:** Mobile requirements from Phase 1-2

#### 13. **"Number Assigned" Email**
**Status:** NEEDS IMPLEMENTATION  
**Ticket:** R2-E05-T013

**What's Needed:**
- Mailer: `app/mailers/business_mailer.rb`
- Method: `#number_assigned(user, business, phone_number)`
- Template: `app/views/business_mailer/number_assigned.html.erb`
- Content:
  - Congratulations message
  - Phone number (E.164 format)
  - Next steps: "Share your form", "Configure settings"
  - Deep link to dashboard
- Trigger: From `AssignTwilioNumberJob` on success

**Reference:** Email templates from Phase 3

#### 14. **Cost Monitoring + Budget Alerts**
**Status:** NEEDS IMPLEMENTATION  
**Ticket:** R2-E05-T014

**What's Needed:**
- Track costs per call
- Monitor budget vs. actual spend
- Alert when approaching budget threshold
- Display cost metrics in admin panel
- Prevent runaway costs

**Implementation Considerations:**
- Store cost data per call
- Aggregate daily/weekly
- Alert admins if overage detected
- Feature flag to disable calls if budget exceeded

**Reference:** Cost monitoring requirements

---

## Implementation Order

### Sprint 1: Admin Panel (16 pts) - CRITICAL FIRST
**Goal:** Enable debugging and operations without SSH

1. **R2-E05-T001** (5 pts) - Admin auth + base interface
2. **R2-E05-T002** (4 pts) - Webhook event inspector
3. **R2-E05-T003** (3 pts) - Entity search
4. **Extras:** Link to Sidekiq UI, admin navigation

**Dependencies:** None - can start immediately  
**Why First:** Required for debugging conversion issues after first paid customer

### Sprint 2: Twilio Integration (9 pts)
**Goal:** Assign phone numbers to businesses

5. **R2-E05-T004** (4 pts) - Twilio client + number provisioning  
6. **R2-E05-T005** (4 pts) - AssignTwilioNumberJob
7. **R2-E05-T013** (2 pts) - "Number Assigned" email

**Dependencies:** Sprint 1 complete

### Sprint 3: Dashboard Foundation (12 pts)
**Goal:** Paid calls appear in dashboard

8. **R2-E05-T006** (3 pts) - Call model (if not exists)
9. **R2-E05-T007** (4 pts) - Paid webhook processing
10. **R2-E05-T008** (3 pts) - BusinessChannel
11. **R2-E05-T009** (5 pts) - Dashboard UI

**Dependencies:** Sprint 2 complete

### Sprint 4: Polish & Operations (12 pts)
**Goal:** Complete Phase 4

12. **R2-E05-T010** (3 pts) - Usage alerts  
13. **R2-E05-T011** (2 pts) - Empty states  
14. **R2-E05-T012** (4 pts) - Mobile-responsive dashboard  
15. **R2-E05-T014** (3 pts) - Cost monitoring

**Dependencies:** Sprint 3 complete

---

## Key Implementation Files

### Controllers to Create
- `app/controllers/admin/base_controller.rb` - Admin auth
- `app/controllers/admin/webhook_events_controller.rb` - Webhook inspector
- `app/controllers/admin/search_controller.rb` - Entity search
- `app/controllers/businesses_controller.rb` - Dashboard (may exist)

### Jobs to Create
- `app/jobs/assign_twilio_number_job.rb` - Number provisioning

### Channels to Create
- `app/channels/business_channel.rb` - Real-time updates

### Mailers
- `app/mailers/business_mailer.rb` - Number assigned email (may exist from Phase 3)

### Models to Create/Extend
- `app/models/call.rb` - Paid calls (check if exists from Phase 2)
- `app/models/phone_number.rb` - Twilio numbers
- Extend `Business` model with phone number association

### Migrations (if needed)
- `create_phone_numbers` table
- Verify `calls` table has `business_id` FK
- Add indexes for performance

---

## Testing Strategy

### Admin Panel Tests
- Request specs: admin-only access enforced
- Reprocess webhook functionality
- Search accuracy across entities
- PII masking in views

### Twilio Integration Tests
- Job specs for number assignment
- VCR cassettes for Twilio API calls
- Idempotency verification

### Dashboard Tests
- System specs for end-to-end flow
- Real-time updates via ActionCable
- Mobile responsiveness at 375px
- Empty states rendering

### Integration Tests
- Full flow: assign number → receive call → dashboard update
- Live webhook processing with idempotency
- BusinessChannel broadcast verification

---

## Dependencies from Phase 3

All Phase 3 infrastructure is complete and ready:
- ✅ Stripe integration with automatic tax
- ✅ Business model with all fields
- ✅ ConvertTrialToBusinessJob working
- ✅ Webhook infrastructure operational
- ✅ Trial to business conversion proven

---

## Risk Assessment

### High Risk
1. **Admin Panel Delayed**
   - Mitigation: Ship admin FIRST (Sprint 1)
   - Impact: Cannot debug conversion issues quickly

2. **Webhook Race Conditions**
   - Mitigation: Use idempotency patterns from Phase 2
   - Test: Concurrent webhook processing

### Medium Risk
1. **Twilio Number Provisioning Failures**
   - Mitigation: Retry logic, circuit breakers
   - Test: VCR cassettes for Twilio API

2. **Dashboard Performance with 50+ Calls**
   - Mitigation: Pagination, lazy loading
   - Target: <500ms load time

### Low Risk
1. **Empty States and Mobile Responsiveness**
   - Mitigation: Existing patterns from Phase 1-2
   - Test: 375px viewport

---

## Exit Criteria (from README)

- ✅ Admin panel operational (webhook inspection, entity search)
- ✅ User can assign Twilio number
- ✅ Inbound calls appear in dashboard in real-time
- ✅ Week 1 success >40% (number + form + dashboard views)
- ✅ Dashboard loads <500ms with 50 calls

---

## Next Steps

1. ✅ Verify Business model has all Phase 4 fields
2. ⏭️ Start Sprint 1: Build admin panel (R2-E05-T001, T002, T003)
3. ⏭️ Implement Twilio number provisioning (Sprint 2)
4. ⏭️ Build dashboard with real-time updates (Sprint 3)
5. ⏭️ Polish and add operational features (Sprint 4)

**Note:** Phase 4.5 (Compliance) should run IN PARALLEL with Phase 4. Do NOT wait for Phase 4 completion before starting compliance work (TCPA requirements).

---

**Analysis Completed:** Ready to start Phase 4 implementation  
**Risk Level:** Low-Medium - Infrastructure is solid, Twilio integration is standard  
**Estimated Velocity:** 12-15 points per sprint (4 sprints total)  
**Critical Path:** Admin panel (Sprint 1) must ship before paid features to enable debugging

