namespace :stripe do
  desc "Create or sync Stripe products and prices"
  task sync_products: :environment do
    puts "Syncing Stripe products and prices..."

    client = StripeClient.new

    # Ensure we have Stripe API key configured
    unless ENV["STRIPE_SECRET_KEY"].present?
      puts "ERROR: STRIPE_SECRET_KEY not set in ENV"
      exit 1
    end

    # Sync Starter plan
    puts "\nCreating Starter plan..."
    starter_plan = sync_plan(
      plan_name: "starter",
      product_name: "Beaker AI - Starter",
      description: "Voice AI phone agent with 100 calls per month",
      price_cents: 199_00,
      calls_included: 100,
      overage_cents_per_call: 150
    )
    puts "  ✓ Starter plan synced: #{starter_plan.stripe_price_id}"

    # Sync Pro plan
    puts "\nCreating Pro plan..."
    pro_plan = sync_plan(
      plan_name: "pro",
      product_name: "Beaker AI - Pro",
      description: "Voice AI phone agent with 300 calls per month",
      price_cents: 499_00,
      calls_included: 300,
      overage_cents_per_call: 125
    )
    puts "  ✓ Pro plan synced: #{pro_plan.stripe_price_id}"

    puts "\n✓ All Stripe products synced successfully!"
    puts "\nTo verify configuration, run:"
    puts "  rails runner \"StripeClient.validate_configuration!\""
  end

  desc "Verify Stripe configuration"
  task verify: :environment do
    begin
      StripeClient.validate_configuration!
      puts "✓ Stripe configuration is valid"
    rescue StripeClient::ConfigurationError => e
      puts "✗ Configuration error: #{e.message}"
      exit 1
    end
  end

  private

  def sync_plan(plan_name:, product_name:, description:, price_cents:, calls_included:, overage_cents_per_call:)
    # Check if we already have this plan with a real price ID
    existing_plan = StripePlan.find_by(plan_name: plan_name)

    if existing_plan && !existing_plan.stripe_price_id.include?("PLACEHOLDER") && !existing_plan.stripe_price_id.include?("CHANGEME")
      puts "  Using existing price ID: #{existing_plan.stripe_price_id}"
      return existing_plan
    end

    # Create product in Stripe
    product = Stripe::Product.create({
      name: product_name,
      description: description
    })

    # Create price in Stripe
    price = Stripe::Price.create({
      product: product.id,
      unit_amount: price_cents,
      currency: "usd",
      recurring: {
        interval: "month"
      },
      metadata: {
        calls_included: calls_included.to_s,
        plan_name: plan_name
      }
    })

    puts "  Created product: #{product.id}"
    puts "  Created price: #{price.id}"

    # Update or create database record
    plan = StripePlan.find_or_create_by!(plan_name: plan_name) do |p|
      p.base_price_cents = price_cents
      p.calls_included = calls_included
      p.overage_cents_per_call = overage_cents_per_call
      p.active = true
    end

    # Update with real price ID
    plan.update!(
      stripe_price_id: price.id,
      base_price_cents: price_cents,
      calls_included: calls_included,
      overage_cents_per_call: overage_cents_per_call,
      active: true
    )

    plan
  rescue Stripe::StripeError => e
    puts "  ✗ Error creating Stripe product: #{e.message}"
    raise
  end
end
