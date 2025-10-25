# Environment Variables Required for Circuit Breaker Implementation

Add these environment variables to your .env file or Rails credentials:

## External API Keys
VAPI_API_KEY=your_vapi_api_key_here
TWILIO_ACCOUNT_SID=your_twilio_account_sid_here  
TWILIO_AUTH_TOKEN=your_twilio_auth_token_here
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key_here

## Webhook URLs (for external services to call back)
TWILIO_STATUS_CALLBACK_URL=http://localhost:3000/webhooks/twilio
TWILIO_VOICE_URL=http://localhost:3000/webhooks/twilio/voice
STRIPE_SUCCESS_URL=http://localhost:3000/dashboard?success=true
STRIPE_CANCEL_URL=http://localhost:3000/dashboard?canceled=true

## Cache and Background Jobs
REDIS_URL=redis://localhost:6379/1

## Email (for magic link authentication)
SMTP_HOST=localhost
SMTP_PORT=587
SMTP_USERNAME=
SMTP_PASSWORD=
SMTP_DOMAIN=localhost

## Development settings
RAILS_ENV=development
SECRET_KEY_BASE=your_secret_key_base_here
