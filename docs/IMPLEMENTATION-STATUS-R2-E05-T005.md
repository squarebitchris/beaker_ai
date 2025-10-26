# Implementation Status: R2-E05-T005 - AssignTwilioNumberJob

**Date:** January 26, 2025  
**Status:** Core Implementation Complete ✅  
**Remaining:** Specs & VCR Cassettes ⏳

---

## ✅ Completed

### 1. AssignTwilioNumberJob (`app/jobs/assign_twilio_number_job.rb`)
- Created with fallback area code logic (requested → 415 → 510 → 650)
- Uses database lock to prevent race conditions
- Idempotent: returns early if business already has number
- Updates Vapi assistant webhook URL with `business_id` parameter
- Creates PhoneNumber record
- Sends "Number Assigned" email
- Comprehensive error handling and Sentry logging

### 2. BusinessChannel (`app/channels/business_channel.rb`)
- Real-time updates for business owners
- Authorization check: only business owners can subscribe
- Broadcast helper method for number assignment

### 3. TwilioClient Enhanced (`app/services/twilio_client.rb`)
- Modified `provision_number` to accept custom `voice_url` parameter
- Maintains backward compatibility with ENV fallback

### 4. VapiClient
- Already has `update_assistant` method ✅ (from previous implementation)
- No changes needed

### 5. Model Extensions
- **Business model** (`app/models/business.rb`):
  - Added `webhook_url_with_business_id` helper method
- **User model** (`app/models/user.rb`):
  - Added `owns?(business)` helper method

### 6. Integration with ConvertTrialToBusinessJob
- Modified `app/jobs/convert_trial_to_business_job.rb` to call `AssignTwilioNumberJob.perform_later(business.id)` after business creation
- Graceful error handling (doesn't fail conversion if number assignment fails)

### 7. BusinessMailer Enhancement (`app/mailers/business_mailer.rb`)
- Added `number_assigned(business_id)` method
- Created HTML and text templates (`app/views/business_mailer/number_assigned.*.erb`)
- Beautiful email with phone number display and next steps

### 8. Environment Variables (`env.example`)
- Added `APP_URL` for webhook callbacks
- Documented production setup

### 9. Webhook URL Strategy
- Twilio voice URL: Points to `/webhooks/twilio/inbound?business_id={id}`
- Vapi assistant webhook: Points to `/webhooks/vapi?business_id={id}`
- Both include `business_id` parameter for routing

---

## ⏳ Remaining Work

### 1. Comprehensive Specs
**Priority:** High  
**Estimated Time:** 2-3 hours

**Files to create:**
- `spec/jobs/assign_twilio_number_job_spec.rb`
  - Happy path with VCR cassette
  - Idempotency test (run twice → one number)
  - Fallback area codes (415 → 510 → 650)
  - Race condition prevention
  - Error handling for no numbers available
  - Webhook URL update verification
  - Email sending
  - BusinessChannel broadcast

- `spec/channels/business_channel_spec.rb`
  - Authorization (owner can subscribe, non-owner rejected)
  - Stream naming

- `spec/mailers/business_mailer_spec.rb`
  - Test `number_assigned` email renders correctly

- Update `spec/jobs/convert_trial_to_business_job_spec.rb`
  - Add test for AssignTwilioNumberJob integration

### 2. VCR Cassettes
**Priority:** Medium  
**Estimated Time:** 1 hour

**Files to create:**
- `spec/vcr_cassettes/twilio/`
  - `provision_number_success.yml`
  - `provision_number_fallback_415.yml`
  - `provision_number_no_numbers.yml`
  - `update_webhook_success.yml`

- `spec/vcr_cassettes/vapi/`
  - `update_assistant_webhook_url.yml`

**Note:** VCR cassettes require actual API calls. Set `VCR_MODE=record` environment variable and run tests to capture responses.

### 3. Webhook Routing Enhancement
**Priority:** Medium  
**Estimated Time:** 1 hour

**File to modify:** `app/services/webhooks/vapi/call_processor.rb`

Currently only handles trial webhooks. Need to add logic to handle business webhooks:

```ruby
def find_callable_from_assistant
  assistant_id = @payload.dig(:assistant, :id)
  return nil unless assistant_id

  # Try business first (paid customers)
  business = Business.find_by(vapi_assistant_id: assistant_id)
  return business if business

  # Fallback to trial (free trials)
  trial = Trial.find_by(vapi_assistant_id: assistant_id)
  return trial if trial

  nil
end
```

### 4. Integration Testing
**Priority:** High  
**Estimated Time:** 30 minutes

**Test scenarios:**
1. Full flow: Business creation → Number assignment → Email sent
2. Retry behavior: Job fails → retries with next area code
3. Race condition: Multiple simultaneous job runs → one number created
4. Idempotency: Run job twice → no duplicate numbers

### 5. Documentation
**Priority:** Low  
**Estimated Time:** 15 minutes

- Add to `README.md` Phase 4 section
- Update `docs/PHASE-4-SETUP-ANALYSIS.md` with completion status

---

## Implementation Notes

### Key Design Decisions

1. **Fallback Strategy:** Area codes fallback in order (requested → 415 → 510 → 650) to ensure high availability
2. **Race Condition Prevention:** Database lock + double-check pattern prevents duplicate number assignment
3. **Idempotency:** Job returns early if phone_number exists (handles webhook retries gracefully)
4. **Error Isolation:** Number assignment failures don't fail business conversion (decoupled, retryable)
5. **Custom Webhook URLs:** Both Twilio and Vapi webhooks include `business_id` parameter for easy routing

### Critical Gotchas

⚠️ **Vapi Webhook URL:** The assistant's `serverUrl` must be updated AFTER number assignment to include `business_id` parameter. This enables the webhook processor to route business calls correctly.

⚠️ **Twilio Voice URL:** Twilio numbers need a custom voice URL pointing to our app's inbound handler (not Vapi bridge). We handle inbound calls and forward to Vapi.

⚠️ **Race Conditions:** Always use database locks (`with_lock`) when checking for existing phone_number. Multiple Sidekiq workers can process the same job concurrently.

---

## Next Steps

1. Write comprehensive specs (follow pattern from `convert_trial_to_business_job_spec.rb`)
2. Record VCR cassettes with actual API calls
3. Update `Webhooks::Vapi::CallProcessor` to handle business webhooks
4. Test end-to-end flow manually
5. Deploy to staging and verify with real Twilio numbers
6. Update documentation

---

## Testing Checklist

- [ ] Job spec with VCR cassettes
- [ ] Idempotency test passes
- [ ] Fallback area codes work
- [ ] Race condition prevention verified
- [ ] Email template renders correctly
- [ ] BusinessChannel broadcasts work
- [ ] Integration test: business creation → number assignment
- [ ] Manual test with real Twilio API (sandbox mode)
- [ ] Check logs for proper error handling

---

**Completed by:** AI Assistant  
**Reviewed by:** Pending  
**Deployment status:** Not deployed

