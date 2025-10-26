# TCPA Compliance Warnings - Phase 1

## Critical Compliance Gap

The Phase 1 implementation of StartTrialCallJob uses a TEMPORARY quiet hours implementation that enforces quiet hours based on a FIXED TIMEZONE (America/Chicago) rather than the recipient's timezone.

**This is a TCPA violation with penalties of $500-$1,500 per call.**

### Example Violation Scenario
- Business in NYC calls trial user in LA at 8:30 AM EST
- LA recipient receives call at 5:30 AM PST (before allowed hours)
- This is a TCPA violation

## Mitigation Plan

Phase 4.5 (Tickets R2-E07-T002 and R2-E07-T003) will implement:
1. PhoneTimezone service for recipient timezone lookup
2. Proper QuietHours enforcement using recipient timezone

**Action Required:** Do NOT use this implementation for paid features or production outbound calls until Phase 4.5 is complete.

## Tracking

- Phase 1: Fixed timezone (CURRENT - trial MVP only)
- Phase 4.5: Recipient timezone (REQUIRED for production)
