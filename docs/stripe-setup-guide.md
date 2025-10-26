# Stripe Setup Guide

This guide walks you through setting up Stripe products programmatically for Beaker AI.

## Overview

Beaker AI has two subscription plans:
- **Starter:** $199/month, 100 calls
- **Pro:** $499/month, 300 calls

Products and prices are created automatically using the Stripe SDK and rake tasks.

## Step-by-Step Setup

### 1. Configure Stripe API Key

Ensure your `.env` file has a Stripe API key:

```bash
# .env
STRIPE_SECRET_KEY=sk_test_your_key_here  # Use sk_live_ for production
```

**Get your API key:**
1. Go to [https://dashboard.stripe.com](https://dashboard.stripe.com)
2. Make sure you're in **Test mode** (toggle in top right for development)
3. Navigate to **Developers** → **API keys**
4. Copy your "Secret key" (starts with `sk_test_`)

### 2. Initialize Database with Placeholders

Run the seed command to create StripePlan records with placeholder price IDs:

```bash
rails db:seed
```

You should see output like:
```
Seeding Stripe plans...
Stripe plans seeding complete!
  - Starter: $199/mo, 100 calls
  - Pro: $499/mo, 300 calls

Run 'rails stripe:sync_products' to create products in Stripe
```

### 3. Create Products in Stripe

Run the sync rake task to create actual products and prices in Stripe:

```bash
rails stripe:sync_products
```

This will:
1. Create "Beaker AI - Starter" product ($199/month, 100 calls)
2. Create "Beaker AI - Pro" product ($499/month, 300 calls)
3. Store the real price IDs in your database

**Expected output:**
```
Syncing Stripe products and prices...

Creating Starter plan...
  Created product: prod_xxx
  Created price: price_xxx
  ✓ Starter plan synced: price_xxx

Creating Pro plan...
  Created product: prod_yyy
  Created price: price_yyy
  ✓ Pro plan synced: price_yyy

✓ All Stripe products synced successfully!
```

### 4. Verify Configuration

Run the validation command to ensure everything is configured correctly:

```bash
rails stripe:verify
```

**Expected output:** `✓ Stripe configuration is valid`

Or manually:
```bash
rails runner "StripeClient.validate_configuration!"
```

## Production Setup

When deploying to production:

1. **Set Live API key in Heroku:**
   ```bash
   heroku config:set STRIPE_SECRET_KEY=sk_live_your_live_key
   ```

2. **Run migration and seed in production:**
   ```bash
   heroku run rails db:migrate
   heroku run rails db:seed
   ```

3. **Sync products with Stripe:**
   ```bash
   heroku run rails stripe:sync_products
   ```
   This creates products using your live Stripe API key.

4. **Verify configuration:**
   ```bash
   heroku run rails stripe:verify
   ```

**Note:** Products created in test mode vs live mode have different IDs. The rake task handles this automatically.

## Testing

### Local Testing

Use Stripe test cards:
- **Success:** `4242 4242 4242 4242`
- **Decline:** `4000 0000 0000 0002`
- **3D Secure:** `4000 0025 0000 3155`

Any future expiry date, any CVC, any ZIP code.

### Stripe CLI (Optional)

Forward webhooks to your local environment:

```bash
stripe listen --forward-to localhost:3000/webhooks/stripe
```

Test checkout flow with:
```bash
stripe trigger checkout.session.completed
```

## Troubleshooting

### "ConfigurationError" when running stripe:verify

**Problem:** Placeholder price IDs still in database

**Solution:**
1. Ensure STRIPE_SECRET_KEY is set in `.env`
2. Run `rails stripe:sync_products` to create real products
3. Re-run `rails stripe:verify`
4. Check: `rails runner "puts StripePlan.all.pluck(:plan_name, :stripe_price_id)"`

### "STRIPE_SECRET_KEY not set in ENV"

**Problem:** Stripe API key missing

**Solution:**
1. Add `STRIPE_SECRET_KEY=sk_test_...` to `.env`
2. Get API key from Stripe Dashboard → Developers → API keys

### Business has wrong call limit (e.g., 500 instead of 300)

**Problem:** Business model using old default value

**Solution:**
1. Check `app/models/business.rb` has `300` for Pro plan
2. Restart Rails server to reload models
3. Test: `rails runner "b = Business.new(plan: 'pro'); puts b.calls_included"` should show 300

### Products already exist in Stripe

**Problem:** Running `stripe:sync_products` multiple times

**Solution:**
The rake task is idempotent:
- First run: Creates products in Stripe
- Subsequent runs: Uses existing price IDs from database
- No duplicates will be created

### Stripe webhook not arriving

**Problem:** Webhook endpoint not configured

**Solution:**
1. Go to Stripe Dashboard → Developers → Webhooks
2. Click "Add endpoint"
3. URL: `https://your-app.com/webhooks/stripe`
4. Events: `checkout.session.completed`, `customer.subscription.*`
5. Copy webhook signing secret to `STRIPE_WEBHOOK_SECRET` in `.env`

## Next Steps

- [x] Configure Stripe API key
- [x] Initialize database with placeholders
- [ ] Run `rails stripe:sync_products` to create products
- [ ] Run `rails stripe:verify` to validate
- [ ] Implement checkout session (R2-E04-T003)
- [ ] Implement webhook handler (R2-E04-T004)

## Quick Reference

**Development Setup:**
```bash
# 1. Get Stripe API key from dashboard
# 2. Add to .env: STRIPE_SECRET_KEY=sk_test_...

# 3. Seed database
rails db:seed

# 4. Create products in Stripe
rails stripe:sync_products

# 5. Verify
rails stripe:verify
```

**Production Setup:**
```bash
# 1. Set live API key
heroku config:set STRIPE_SECRET_KEY=sk_live_...

# 2. Migrate and seed
heroku run rails db:migrate
heroku run rails db:seed

# 3. Sync products
heroku run rails stripe:sync_products

# 4. Verify
heroku run rails stripe:verify
```

