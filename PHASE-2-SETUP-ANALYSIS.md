# Phase 2 Setup Analysis

## Current Status Review

### ✅ What's Already Setup

#### 1. Database Models
- ✅ **Trial** model exists and is complete
- ✅ **Call** model exists with polymorphic association
- ✅ **WebhookEvent** model exists for idempotency
- ✅ **User** model with Devise authentication

#### 2. Webhook Infrastructure
- ✅ **WebhooksController** exists with signature verification
- ✅ Vapi signature verification implemented
- ✅ Route configured: `POST /webhooks/vapi`
- ✅ **WebhookProcessorJob** exists but needs Phase 2 implementation
- ✅ Idempotency protection (unique constraint on provider + event_id)

#### 3. Services & Clients
- ✅ **VapiClient** with circuit breaker
- ✅ **PromptBuilder** for assistant configuration
- ✅ **KbGenerator** for knowledge base creation
- ✅ **ApiClientBase** with retry logic

#### 4. Background Jobs
- ✅ **CreateTrialAssistantJob** working
- ✅ **StartTrialCallJob** working
- ✅ **TrialReaperJob** working
- ✅ **WebhookProcessorJob** exists (needs Phase 2 logic)

#### 5. Sidekiq Configuration
- ✅ Sidekiq Web UI at `/sidekiq` (admin-protected)
- ✅ Sidekiq-Cron configured for recurring jobs
- ✅ Redis connection working
- ✅ Queue configuration (critical, default, low)

---

## ❌ What's Missing for Phase 2

### Critical Gaps

#### 1. **TrialCall Model Does NOT Exist**
The Phase 2 spec calls for a separate `trial_calls` table, but the current implementation uses a polymorphic `calls` table.

**Decision Needed:**
- Option A: Create new `trial_calls` table (follows spec exactly)
- Option B: Use existing `calls` table with `callable_type: "Trial"` (simpler, already implemented)

**Recommendation:** Use existing `calls` table (Option B) because:
- Already polymorphic and working
- Avoids duplicate schema
- Can handle both trial and paid calls
- Matches current codebase patterns

#### 2. **Webhook Processing Logic**
`WebhookProcessorJob` has placeholder logic for Vapi:
```ruby
when [ "vapi", /call\./ ]
  # Webhooks::Vapi::CallProcessor.new(event) - Phase 2
  Rails.logger.info("[Webhook] Vapi call event - processor not yet implemented")
  nil
```

**Needs:**
- `Webhooks::Vapi::CallProcessor` service
- Logic to parse Vapi webhook payload
- Create/update Call records
- Extract lead data from transcript/function calls

#### 3. **Missing Services**
According to spec:
- ❌ **LeadExtractor** service
- ❌ **IntentClassifier** service  
- ❌ **VapiPayload** helper (for safe digging)

#### 4. **ViewComponents for Mini-Report**
- ❌ **CallCard** component (with recording + transcript)
- ❌ **AudioPlayer** component (keyboard accessible)
- ❌ Existing components may need updates

#### 5. **ActionCable/Turbo Streams**
- ❌ **TrialSessionChannel** not created
- Need to broadcast call updates to trial show page

#### 6. **Database Fields**
The existing `calls` table may need additional fields:
- ✅ `vapi_call_id` (already exists)
- ✅ `recording_url` (already exists)
- ✅ `transcript` (already exists)
- ✅ `extracted_lead` (already exists, jsonb)
- ✅ `status` (already exists)
- ✅ `duration_seconds` (already exists)
- ✅ `started_at`, `ended_at` (already exists)

**May need to add:**
- `intent` field (string enum: lead_intake, scheduling, info, other)
- Confirm `extracted_lead` structure matches spec

---

## Environment Variables Check

### Required for Phase 2
```bash
# Already configured (Phase 0-1):
✅ VAPI_API_KEY
✅ VAPI_WEBHOOK_SECRET
✅ OPENAI_API_KEY
✅ REDIS_URL

# Need to verify:
⚠️ APP_HOST (should be set for webhooks)
⚠️ Sidekiq Web UI secret (admin auth working?)
```

---

## Action Plan for Phase 2 Start

### Sprint 1: Webhook Processing Backend (13pts)

#### R1-E03-T001: Vapi Webhook Endpoint ✅ (Already exists)
**Status:** COMPLETE
- WebhooksController with signature verification ✅
- Route `POST /webhooks/vapi` configured ✅  
- Idempotency via WebhookEvent ✅
- **Next:** Just needs proper event_id extraction

#### R1-E03-T002: ProcessVapiEventJob (4pts)
**Status:** NEEDS IMPLEMENTATION
**Tasks:**
1. Create `Webhooks::Vapi::CallProcessor` service
2. Update `WebhookProcessorJob` to call processor
3. Parse Vapi payload structure
4. Create/update Call records from webhook

**Key Events to Process:**
- `call-started` → Create Call record with `status: "initiated"`
- `call-ended` → Update Call with duration, recording, transcript
- `speech-update` → Update transcript in real-time
- `function-call` → Extract lead data from function calls

**Files to create:**
- `app/services/webhooks/vapi/call_processor.rb`
- `app/jobs/process_vapi_event_job.rb` (or update existing)

#### R1-E03-T003: LeadExtractor Service (4pts)
**Status:** NEEDS IMPLEMENTATION
**Tasks:**
1. Parse function calls from Vapi payload
2. Extract structured data (name, phone, email, intent)
3. Handle various function call formats
4. Fallback to transcript parsing

**Files to create:**
- `app/services/lead_extractor.rb`

#### R1-E03-T004: IntentClassifier Service (3pts)
**Status:** NEEDS IMPLEMENTATION
**Tasks:**
1. Classify intent from transcript/function calls
2. Categories: lead_intake, scheduling, info, other
3. Confidence scoring

**Files to create:**
- `app/services/intent_classifier.rb`

#### R1-E03-T005: TrialCall Model (2pts) 
**Status:** ALREADY EXISTS (via Call model)
**Decision:** Use existing `calls` table with polymorphic `callable`
**Tasks:**
1. Verify all fields exist in Call model
2. Add `intent` field to calls table (migration)
3. Update Call model with intent enum

---

### Sprint 2: UI & Real-Time (12pts)

#### R1-E03-T006: CallCard ViewComponent (5pts)
**Status:** NEEDS IMPLEMENTATION
**Files to create:**
- `app/components/voice/call_card_component.rb`
- `app/components/voice/call_card_component.html.erb`

#### R1-E03-T007: AudioPlayer Component (4pts)
**Status:** NEEDS IMPLEMENTATION
**Files to create:**
- `app/components/voice/audio_player_component.rb`
- `app/javascript/controllers/audio_player_controller.js`

#### R1-E03-T008: TrialSessionChannel (4pts)
**Status:** NEEDS IMPLEMENTATION
**Files to create:**
- `app/channels/trial_session_channel.rb`
- Update trial show view to subscribe to channel

#### R1-E03-T009: Mini-Report UI (5pts)
**Status:** NEEDS IMPLEMENTATION
**Tasks:**
- Mobile-first layout (375px tested)
- Captured fields above transcript
- 60px tap targets for audio player
- Real-time Turbo Stream updates

#### R1-E03-T010: Upgrade CTA (2pts)
**Status:** NEEDS IMPLEMENTATION
**Tasks:**
- Add "Go Live" button to mini-report
- Click tracking
- Redirect to Stripe checkout (Phase 3)

#### R1-E03-T011: PurgeOldTrialsJob (2pts)
**Status:** MAY EXIST
**Check:** Does `TrialReaperJob` do this already?
**Need:** 7-day retention policy for non-converted trials

#### R1-E03-T012: Race Condition Prevention (3pts)
**Status:** PARTIALLY DONE
**Tasks:**
- Verify unique constraints on Call model
- Add `with_lock` in ProcessVapiEventJob
- Test concurrent webhook processing

---

## Code Review Needed

### 1. WebhookProcessorJob
Current implementation:
```ruby
when [ "vapi", /call\./ ]
  Rails.logger.info("[Webhook] Vapi call event - processor not yet implemented")
  nil
```

**Action:** Implement processor and call it

### 2. Vapi Event ID Extraction
Current in WebhooksController:
```ruby
def webhook_event_id
  when "vapi"
    parsed_body.dig("message", "id")
  end
```

**Issue:** This doesn't match Vapi's actual webhook format. Based on [Vapi documentation](https://docs.vapi.ai/server-url), the correct structure is:
```ruby
def webhook_event_id
  when "vapi"
    parsed_body.dig("call", "id")  # Use call.id, not message.id
  end
```

**Fix needed:** Update WebhooksController to use `call.id` for Vapi webhooks.

### 3. Call Model Fields
Check if these fields exist:
- `intent` (string)
- All other fields seem present

### 4. Trial-Call Association
Current:
```ruby
# Trial model
has_many :calls, as: :callable, dependent: :destroy

# Call model  
belongs_to :callable, polymorphic: true
```

**Verify:** This works for Phase 2 requirements

---

## Testing Requirements

### 1. Webhook Tests
Create: `spec/requests/webhooks/vapi_spec.rb`
- Test signature verification
- Test idempotency (duplicate events)
- Test job enqueuing

### 2. Job Tests
Create: `spec/jobs/process_vapi_event_job_spec.rb`
- Test webhook → Call record creation
- Test lead extraction
- Test intent classification

### 3. Service Tests
Create:
- `spec/services/lead_extractor_spec.rb`
- `spec/services/intent_classifier_spec.rb`

### 4. System Tests
Create: `spec/system/mini_report_spec.rb`
- End-to-end webhook → UI update
- Real-time Turbo Stream display
- Mobile responsive (375px)

---

## Environment Setup Checklist

### Local Development
- [ ] Redis running: `redis-cli ping`
- [ ] Sidekiq worker running: `bin/dev` or manual
- [ ] Environment variables set (`.env`)
- [ ] Database migrated: `rails db:migrate`
- [ ] Test webhook endpoint accessible

### Testing Vapi Webhooks Locally

#### Method 1: Direct ngrok (Simple)
```bash
# Install ngrok
brew install ngrok

# Start ngrok tunnel to your Rails app
ngrok http 3000

# Get URL and configure in Vapi dashboard
# https://your-app.vapi.ai/settings/webhooks
# Webhook URL: https://xxxx.ngrok.io/webhooks/vapi
# Secret: <set in .env as VAPI_WEBHOOK_SECRET>
```

#### Method 2: Vapi CLI + ngrok (Advanced)
```bash
# Terminal 1: Start ngrok tunnel to Vapi CLI listener
ngrok http 4242

# Terminal 2: Start Vapi webhook forwarder
vapi listen --forward-to localhost:3000/webhooks/vapi

# Configure Vapi dashboard webhook URL to: https://xxxx.ngrok.io
# This forwards: Vapi → ngrok → vapi listen → your Rails app
```

#### Vapi Webhook Events
Based on [Vapi documentation](https://docs.vapi.ai/server-url), your webhook will receive:

**Call Lifecycle Events:**
- `call-started` - Call initiated
- `call-ended` - Call completed with summary data
- `speech-update` - Real-time transcript updates
- `function-call` - When assistant calls tools/functions
- `assistant-request` - Dynamic configuration requests
- `hang-notification` - When assistant fails to reply

**Key Event Structure:**
```json
{
  "type": "call-ended",
  "call": {
    "id": "call_abc123",
    "duration": 120,
    "recordingUrl": "https://...",
    "transcript": "...",
    "functionCalls": [...]
  }
}
```

#### Webhook Security
- **Signature Verification**: Vapi sends `x-vapi-signature` header
- **HMAC-SHA256**: Verify with your `VAPI_WEBHOOK_SECRET`
- **Idempotency**: Use `call.id` as unique identifier
- **Response Time**: Keep responses under 10 seconds

### Production (Heroku)
- [ ] Vapi webhook URL configured
- [ ] `VAPI_WEBHOOK_SECRET` set in Heroku config
- [ ] Redis addon connected
- [ ] Worker dyno scaled up
- [ ] Sidekiq Web UI accessible (admin user)

---

## Recommendations

### Start with R1-E03-T002
Begin implementation with ProcessVapiEventJob because:
1. It's the core of the feature
2. Everything else depends on it
3. Can test with real Vapi webhooks
4. Will reveal missing pieces

### Use Existing Call Model
Don't create a separate `trial_calls` table. The polymorphic `calls` table is already:
- ✅ Complete with all needed fields
- ✅ Properly indexed
- ✅ Connected to Trial model
- ✅ Ready for Phase 4 paid calls

### Implement in Order
1. **Backend first** (T001-T005): Webhook processing, data extraction
2. **Services** (LeadExtractor, IntentClassifier): Business logic
3. **UI** (T006-T009): Mini-report components
4. **Real-time** (T008): Turbo Streams
5. **Polish** (T010-T012): CTAs, cleanup, race conditions

---

## Next Steps

1. ✅ Review Phase 2 tickets in detail
2. ✅ Verify environment setup
3. ✅ Check test webhook delivery
4. ✅ Start with R1-E03-T002
5. ⏭️ Create VapiCallProcessor service
6. ⏭️ Add `intent` field to Call model
7. ⏭️ Build LeadExtractor service

---

**Analysis Completed:** Ready to start Phase 2 implementation
**Risk Level:** Low - Infrastructure is solid
**Estimated Velocity:** 12-13 points per sprint

