# Vapi.ai Webhook Payload Structure

This document describes the structure of webhook payloads sent by Vapi.ai to our webhook endpoint at `POST /webhooks/vapi`.

## Authentication

Vapi webhooks use HMAC-SHA256 signature verification:
- **Header:** `x-vapi-signature`
- **Algorithm:** HMAC-SHA256
- **Secret:** `VAPI_WEBHOOK_SECRET` environment variable

## Event Types

Vapi sends different event types for various call lifecycle events:

- `call.started` - Call initiated
- `call.ringing` - Call is ringing
- `call.answered` - Call answered
- `call.ended` - Call completed
- `recording.available` - Recording URL available
- `transcript.chunk` - Real-time transcript updates
- `assistant.created` - Assistant created
- `assistant.updated` - Assistant updated

## Payload Structure

### Base Structure

```json
{
  "type": "call.ended",
  "call": {
    "id": "call_123456789",
    "status": "ended",
    "duration": 120,
    "recordingUrl": "https://storage.vapi.ai/recordings/call_123456789.mp3",
    "transcript": "Agent: Hello...",
    "cost": 0.15,
    "startedAt": "2025-01-26T10:30:00Z",
    "endedAt": "2025-01-26T10:32:00Z"
  },
  "assistant": {
    "id": "asst_abc123def456",
    "name": "Sarah - HVAC Assistant"
  },
  "functionCalls": [
    {
      "name": "capture_lead",
      "parameters": {
        "name": "John Smith",
        "phone": "555-123-4567",
        "email": "",
        "intent": "quote_request",
        "notes": "Needs quote for new AC unit"
      }
    }
  ]
}
```

### Event ID Extraction

For idempotency, we extract the event ID from:
```ruby
parsed_body.dig("call", "id")  # e.g., "call_123456789"
```

### Event Type Extraction

We extract the event type from:
```ruby
parsed_body["type"]  # e.g., "call.ended"
```

## Call Object Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique call identifier |
| `status` | string | Call status (initiated, ringing, answered, ended, failed) |
| `duration` | integer | Call duration in seconds |
| `recordingUrl` | string | URL to call recording (if available) |
| `transcript` | string | Full call transcript |
| `cost` | number | Call cost in USD |
| `startedAt` | string | ISO 8601 timestamp when call started |
| `endedAt` | string | ISO 8601 timestamp when call ended |

## Assistant Object Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Assistant identifier |
| `name` | string | Assistant display name |

## Function Calls

Vapi can execute custom functions during calls. For lead capture, we expect:

```json
{
  "name": "capture_lead",
  "parameters": {
    "name": "Customer Name",
    "phone": "Phone Number",
    "email": "Email Address",
    "intent": "Intent Classification",
    "notes": "Additional Notes"
  }
}
```

## Implementation Notes

1. **Idempotency:** Use `call.id` as the unique event identifier
2. **Signature Verification:** Always verify HMAC-SHA256 signature
3. **Error Handling:** Return 200 OK even for duplicate events
4. **Processing:** Enqueue `WebhookProcessorJob` for async processing

## Testing

Use the VCR cassette at `spec/vcr_cassettes/vapi/webhook_call_ended.yml` for testing with realistic payload data.

## References

- [Vapi.ai Documentation](https://docs.vapi.ai/)
- [Webhook Security](https://docs.vapi.ai/server-url)
