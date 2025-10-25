# Beaker AI Environment Variables
# Copy this file to .env and fill in your actual values

# Database Configuration
DATABASE_URL=postgresql://username:password@localhost:5432/beaker_ai_development

# Observability & Monitoring
SENTRY_DSN=your_sentry_dsn_here
SENTRY_TRACES_SAMPLE_RATE=0.1
SENTRY_RELEASE=optional_git_sha_or_version
RAILS_LOG_LEVEL=info

# External API Keys
VAPI_API_KEY=your_vapi_api_key_here
VAPI_WEBHOOK_SECRET=your_vapi_webhook_secret_here

TWILIO_ACCOUNT_SID=your_twilio_account_sid_here
TWILIO_AUTH_TOKEN=your_twilio_auth_token_here
TWILIO_STATUS_CALLBACK_URL=https://your-domain.com/webhooks/twilio
TWILIO_VOICE_URL=https://your-domain.com/twilio/voice

STRIPE_SECRET_KEY=your_stripe_secret_key_here
STRIPE_WEBHOOK_SECRET=your_stripe_webhook_secret_here
STRIPE_SUCCESS_URL=https://your-domain.com/stripe/success
STRIPE_CANCEL_URL=https://your-domain.com/stripe/cancel

# Email Configuration (SendGrid/Resend)
SENDGRID_API_KEY=your_sendgrid_api_key_here
# OR
RESEND_API_KEY=your_resend_api_key_here

# Application URLs
RAILS_HOST=localhost:3000
RAILS_URL=http://localhost:3000

# Security
SECRET_KEY_BASE=your_secret_key_base_here

# Development Only
# These are automatically set in development
# RAILS_ENV=development
# RAILS_LOG_TO_STDOUT=true