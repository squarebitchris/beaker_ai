class StripeClient < ApiClientBase
  def initialize
    Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY")
  end

  def create_checkout_session(price_id:, customer_email:, metadata: {}, idempotency_key: nil)
    with_circuit_breaker(name: "stripe:create_checkout_session") do
      params = {
        mode: "subscription",
        line_items: [ {
          price: price_id,
          quantity: 1
        } ],
        customer_email: customer_email,
        success_url: ENV.fetch("STRIPE_SUCCESS_URL"),
        cancel_url: ENV.fetch("STRIPE_CANCEL_URL"),
        metadata: metadata,
        automatic_tax: { enabled: true }
      }

      options = {}
      options[:idempotency_key] = idempotency_key if idempotency_key

      Stripe::Checkout::Session.create(params, options)
    end
  rescue Stripe::StripeError => e
    raise ApiError, "Stripe API error: #{e.message}"
  end

  def get_subscription(subscription_id:)
    with_circuit_breaker(name: "stripe:get_subscription", fallback: -> { nil }) do
      Stripe::Subscription.retrieve(subscription_id)
    end
  rescue Stripe::InvalidRequestError => e
    nil
  rescue Stripe::StripeError => e
    raise ApiError, "Stripe API error: #{e.message}"
  end

  def get_customer(customer_id:)
    with_circuit_breaker(name: "stripe:get_customer", fallback: -> { nil }) do
      Stripe::Customer.retrieve(customer_id)
    end
  rescue Stripe::InvalidRequestError => e
    nil
  rescue Stripe::StripeError => e
    raise ApiError, "Stripe API error: #{e.message}"
  end

  def create_customer(email:, metadata: {})
    with_circuit_breaker(name: "stripe:create_customer") do
      Stripe::Customer.create({
        email: email,
        metadata: metadata
      })
    end
  rescue Stripe::StripeError => e
    raise ApiError, "Stripe API error: #{e.message}"
  end

  def cancel_subscription(subscription_id:)
    with_circuit_breaker(name: "stripe:cancel_subscription") do
      subscription = Stripe::Subscription.retrieve(subscription_id)
      subscription.delete
    end
  rescue Stripe::StripeError => e
    raise ApiError, "Stripe API error: #{e.message}"
  end

  def get_checkout_session(session_id:)
    with_circuit_breaker(name: "stripe:get_checkout_session") do
      Stripe::Checkout::Session.retrieve(session_id)
    end
  rescue Stripe::InvalidRequestError => e
    Rails.logger.warn("[Stripe] Checkout session not found: #{session_id}")
    nil
  rescue Stripe::StripeError => e
    raise ApiError, "Stripe API error: #{e.message}"
  end

  def get_payment_intent(payment_intent_id:)
    with_circuit_breaker(name: "stripe:get_payment_intent", fallback: -> { nil }) do
      Stripe::PaymentIntent.retrieve(payment_intent_id)
    end
  rescue Stripe::InvalidRequestError => e
    nil
  rescue Stripe::StripeError => e
    raise ApiError, "Stripe API error: #{e.message}"
  end

  def self.validate_configuration!
    errors = []

    StripePlan.active.find_each do |plan|
      if plan.stripe_price_id.include?("PLACEHOLDER") || plan.stripe_price_id.include?("CHANGEME")
        errors << "#{plan.plan_name} plan has placeholder price ID: #{plan.stripe_price_id}"
      end

      # Verify price exists in Stripe (optional, can be expensive)
      # begin
      #   Stripe::Price.retrieve(plan.stripe_price_id)
      # rescue Stripe::InvalidRequestError => e
      #   errors << "#{plan.plan_name} price ID invalid: #{e.message}"
      # end
    end

    raise ConfigurationError, errors.join("; ") if errors.any?

    true
  end

  class ConfigurationError < StandardError; end
end
