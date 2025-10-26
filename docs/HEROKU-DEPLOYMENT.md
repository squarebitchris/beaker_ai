# Heroku Deployment Guide - Beaker AI

## Overview

This guide walks you through deploying Beaker AI to Heroku as a production environment using test API keys for Phase 0-1 development.

**App Name:** `beaker-ai`  
**Stack:** heroku-24  
**Monthly Cost:** ~$19/month (basic web + worker + postgres)

## Prerequisites

1. **Heroku CLI installed:**
   ```bash
   brew tap heroku/brew && brew install heroku
   ```

2. **Git repository initialized:**
   ```bash
   git status  # Verify you're in the beaker_ai directory
   ```

3. **Rails master key exists:**
   ```bash
   cat config/master.key  # Should output your master key
   ```

## Step 1: Create Heroku App

```bash
# Login to Heroku
heroku login

# Create app named "beaker-ai" with heroku-24 stack
heroku create beaker-ai --stack heroku-24

# Verify app was created
heroku apps:info -a beaker-ai
```

**Note:** If `beaker-ai` is already taken, Heroku will suggest alternatives or you can choose a different name (update app.json and env.example accordingly).

## Step 2: Add PostgreSQL Addon

```bash
# Add PostgreSQL essential-0 plan ($5/month)
heroku addons:create heroku-postgresql:essential-0 -a beaker-ai

# Verify DATABASE_URL was automatically set
heroku config:get DATABASE_URL -a beaker-ai

# Check database info
heroku pg:info -a beaker-ai
```

## Step 3: Configure Buildpacks

```bash
# Add Node.js buildpack (index 1 - runs first for asset compilation)
heroku buildpacks:add --index 1 heroku/nodejs -a beaker-ai

# Add Ruby buildpack (index 2 - runs second)
heroku buildpacks:add --index 2 heroku/ruby -a beaker-ai

# Verify buildpacks order
heroku buildpacks -a beaker-ai
```

**Expected output:**
```
=== beaker-ai Buildpack URLs
1. heroku/nodejs
2. heroku/ruby
```

## Step 4: Set Environment Variables

### Required Variables

```bash
# Set Rails master key (REQUIRED for app to boot)
heroku config:set RAILS_MASTER_KEY=$(cat config/master.key) -a beaker-ai

# Set app host
heroku config:set APP_HOST=beaker-ai.herokuapp.com -a beaker-ai
```

### API Keys (Use TEST credentials)

**Get test credentials from:**
- Vapi: https://vapi.ai (get test API key)
- Twilio: https://console.twilio.com (use test credentials)
- Stripe: https://dashboard.stripe.com/test/apikeys (use sk_test_... keys)
- Sentry: https://sentry.io (your project DSN)

```bash
# Set API keys (replace with your actual test keys)
heroku config:set \
  VAPI_API_KEY=your_vapi_test_key \
  TWILIO_ACCOUNT_SID=your_test_account_sid \
  TWILIO_AUTH_TOKEN=your_test_auth_token \
  STRIPE_SECRET_KEY=sk_test_your_key \
  STRIPE_WEBHOOK_SECRET=whsec_test_your_secret \
  SENTRY_DSN=your_sentry_dsn \
  -a beaker-ai
```

### Webhook URLs

```bash
# Set webhook callback URLs
heroku config:set \
  TWILIO_STATUS_CALLBACK_URL=https://beaker-ai.herokuapp.com/webhooks/twilio \
  TWILIO_VOICE_URL=https://beaker-ai.herokuapp.com/voice \
  STRIPE_SUCCESS_URL=https://beaker-ai.herokuapp.com/success \
  STRIPE_CANCEL_URL=https://beaker-ai.herokuapp.com/cancel \
  -a beaker-ai
```

### Optional: Email Configuration

```bash
# If using SendGrid for email delivery
heroku config:set \
  SENDGRID_API_KEY=your_sendgrid_key \
  MAILER_FROM=noreply@beaker-ai.herokuapp.com \
  -a beaker-ai
```

### Verify Configuration

```bash
# View all config vars
heroku config -a beaker-ai

# Should see DATABASE_URL, RAILS_MASTER_KEY, APP_HOST, and all API keys
```

## Step 5: Deploy to Heroku

```bash
# Add Heroku remote (if not already added)
heroku git:remote -a beaker-ai

# Deploy main branch to Heroku
git push heroku main

# Watch the deployment logs
# You should see:
# - Node.js buildpack installing dependencies
# - Ruby buildpack installing gems
# - Asset precompilation (build, build:css)
# - Release phase running migrations
```

**First deployment takes 3-5 minutes.**

## Step 6: Scale Worker Dyno

```bash
# Scale web dyno to 1 (should already be running)
heroku ps:scale web=1 -a beaker-ai

# Scale worker dyno to 1 (CRITICAL - processes SolidQueue jobs)
heroku ps:scale worker=1 -a beaker-ai

# Verify both dynos are running
heroku ps -a beaker-ai
```

**Expected output:**
```
=== web (Basic): bundle exec puma -C config/puma.rb (1)
web.1: up

=== worker (Basic): bundle exec rake solid_queue:start (1)
worker.1: up
```

## Step 7: Verify Deployment

### Check App Health

```bash
# Open app in browser
heroku open -a beaker-ai

# Should see Rails app (even if it's a blank page for now)

# Check health endpoint
curl https://beaker-ai.herokuapp.com/up

# Should return: "Rails is up and running"
```

### Check Logs

```bash
# Tail live logs
heroku logs --tail -a beaker-ai

# Filter by dyno type
heroku logs --tail --dyno web -a beaker-ai
heroku logs --tail --dyno worker -a beaker-ai

# Look for any errors or warnings
```

### Access Rails Console

```bash
# Open Rails console on Heroku
heroku run rails console -a beaker-ai

# Test database connection
> User.count
> Trial.count
> WebhookEvent.count

# Exit console
> exit
```

### Run Database Migrations (if needed)

```bash
# Migrations run automatically via release phase
# But you can run them manually if needed:
heroku run rails db:migrate -a beaker-ai

# Check migration status
heroku run rails db:migrate:status -a beaker-ai
```

## Step 8: Configure External Services

### Stripe Webhooks

1. Go to https://dashboard.stripe.com/test/webhooks
2. Click "Add endpoint"
3. URL: `https://beaker-ai.herokuapp.com/webhooks/stripe`
4. Select events: `checkout.session.completed`, `customer.subscription.*`
5. Copy webhook signing secret
6. Update Heroku config:
   ```bash
   heroku config:set STRIPE_WEBHOOK_SECRET=whsec_your_new_secret -a beaker-ai
   ```

### Twilio Webhooks

1. Configure phone number webhooks in Twilio console
2. Status Callback URL: `https://beaker-ai.herokuapp.com/webhooks/twilio`
3. Voice URL: `https://beaker-ai.herokuapp.com/voice`

### Vapi Webhooks

1. Configure assistant webhooks in Vapi dashboard
2. Webhook URL: `https://beaker-ai.herokuapp.com/webhooks/vapi`

## Ongoing Operations

### Viewing Logs

```bash
# Tail all logs
heroku logs --tail -a beaker-ai

# Last 100 lines
heroku logs -n 100 -a beaker-ai

# Filter by source
heroku logs --source app -a beaker-ai
heroku logs --source heroku -a beaker-ai
```

### Deploying Updates

```bash
# Make your code changes, commit them
git add .
git commit -m "Your commit message"

# Deploy to Heroku
git push heroku main

# Migrations run automatically via release phase
```

### Restarting Dynos

```bash
# Restart all dynos
heroku restart -a beaker-ai

# Restart specific dyno type
heroku restart web -a beaker-ai
heroku restart worker -a beaker-ai
```

### Database Operations

```bash
# Open database console
heroku pg:psql -a beaker-ai

# Backup database
heroku pg:backups:capture -a beaker-ai

# Download latest backup
heroku pg:backups:download -a beaker-ai

# Restore from backup
heroku pg:backups:restore b001 -a beaker-ai
```

### Monitoring

```bash
# Check dyno status
heroku ps -a beaker-ai

# Check database stats
heroku pg:info -a beaker-ai

# View metrics (if you have metrics addon)
heroku addons:open metrics -a beaker-ai
```

## Troubleshooting

### App Won't Boot

```bash
# Check logs for errors
heroku logs --tail -a beaker-ai

# Common issues:
# 1. Missing RAILS_MASTER_KEY
heroku config:set RAILS_MASTER_KEY=$(cat config/master.key) -a beaker-ai

# 2. Database not connected
heroku pg:info -a beaker-ai

# 3. Asset compilation failed
# Check package.json has correct build scripts
```

### Worker Not Processing Jobs

```bash
# Check worker logs
heroku logs --tail --dyno worker -a beaker-ai

# Verify worker is running
heroku ps -a beaker-ai

# Scale worker if not running
heroku ps:scale worker=1 -a beaker-ai

# Check SolidQueue in Rails console
heroku run rails console -a beaker-ai
> SolidQueue::Job.count
```

### Database Connection Issues

```bash
# Check DATABASE_URL is set
heroku config:get DATABASE_URL -a beaker-ai

# Test connection
heroku run rails console -a beaker-ai
> ActiveRecord::Base.connection.execute("SELECT 1")
```

### SSL/HTTPS Issues

Rails is configured with `force_ssl = true`. Heroku provides free SSL certificates automatically. If you see SSL errors:

```bash
# Check app is accessible via HTTPS
curl https://beaker-ai.herokuapp.com/up

# SSL should work immediately on *.herokuapp.com domains
```

## Cost Optimization

Current setup: ~$19/month
- Web dyno (basic): $7/month
- Worker dyno (basic): $7/month
- Postgres essential-0: $5/month

**To reduce costs during development:**

```bash
# Scale down worker when not needed
heroku ps:scale worker=0 -a beaker-ai

# Scale back up when testing webhooks
heroku ps:scale worker=1 -a beaker-ai
```

**Note:** Without worker dyno, webhooks won't process!

## Upgrading to Production API Keys

When ready for Phase 3 (real payments):

1. Get production API keys from Stripe, Twilio, Vapi
2. Update Heroku config:
   ```bash
   heroku config:set \
     STRIPE_SECRET_KEY=sk_live_... \
     VAPI_API_KEY=vapi_prod_... \
     -a beaker-ai
   ```
3. Update webhook endpoints to use production credentials
4. Test thoroughly before going live!

## Validation Checklist

After deployment, verify:

- [ ] App accessible at https://beaker-ai.herokuapp.com
- [ ] Health check returns 200: `curl https://beaker-ai.herokuapp.com/up`
- [ ] Both web and worker dynos running: `heroku ps -a beaker-ai`
- [ ] Database connected: `heroku pg:info -a beaker-ai`
- [ ] Rails console accessible: `heroku run rails console -a beaker-ai`
- [ ] Logs are clean (no errors): `heroku logs --tail -a beaker-ai`
- [ ] SSL/HTTPS working (force_ssl enabled)
- [ ] Environment variables set: `heroku config -a beaker-ai`
- [ ] Migrations ran successfully (check logs)
- [ ] SolidQueue worker processing jobs

## Next Steps

1. Set up monitoring (Sentry errors should appear in dashboard)
2. Configure external webhooks (Stripe, Twilio, Vapi)
3. Test magic-link authentication (will need SendGrid or email configured)
4. Begin Phase 1 development (Trial Flow)

## Support Resources

- Heroku Dev Center: https://devcenter.heroku.com/
- Heroku Postgres: https://devcenter.heroku.com/articles/heroku-postgresql
- Rails on Heroku: https://devcenter.heroku.com/articles/getting-started-with-rails8

---

**Created:** October 26, 2025  
**Ticket:** R1-E01-T011 - Deploy to staging (Heroku)

