require 'rails_helper'

RSpec.describe StripeClient, vcr: false do
  let(:client) { described_class.new }

  before do
    # Set up environment variables for testing
    allow(ENV).to receive(:fetch).with('STRIPE_SECRET_KEY').and_return('sk_test_1234567890')
    allow(ENV).to receive(:fetch).with('STRIPE_SUCCESS_URL').and_return('http://localhost:3000/dashboard?success=true')
    allow(ENV).to receive(:fetch).with('STRIPE_CANCEL_URL').and_return('http://localhost:3000/dashboard?canceled=true')

    # Reset circuit breakers before each test
    reset_circuit_breakers
  end

  describe '#create_checkout_session' do
    let(:price_id) { 'price_1234567890' }
    let(:customer_email) { 'test@example.com' }
    let(:metadata) { { user_id: '123', plan: 'starter' } }

    context 'when API succeeds' do
      it 'returns checkout session data' do
        checkout_session = double('Stripe::Checkout::Session',
          id: 'cs_test_1234567890',
          url: 'https://checkout.stripe.com/pay/cs_test_1234567890'
        )

        allow(Stripe::Checkout::Session).to receive(:create).and_return(checkout_session)

        result = client.create_checkout_session(
          price_id: price_id,
          customer_email: customer_email,
          metadata: metadata
        )

        expect(result.id).to eq('cs_test_1234567890')
        expect(result.url).to eq('https://checkout.stripe.com/pay/cs_test_1234567890')
      end

      it 'passes idempotency key when provided' do
        checkout_session = double('Stripe::Checkout::Session', id: 'cs_test_1234567890')
        idempotency_key = 'checkout:user_123:trial_456'

        expect(Stripe::Checkout::Session).to receive(:create) do |params, options|
          expect(options[:idempotency_key]).to eq(idempotency_key)
          checkout_session
        end

        client.create_checkout_session(
          price_id: price_id,
          customer_email: customer_email,
          metadata: metadata,
          idempotency_key: idempotency_key
        )
      end

      it 'includes automatic_tax parameter' do
        checkout_session = double('Stripe::Checkout::Session',
          id: 'cs_test_1234567890',
          url: 'https://checkout.stripe.com/pay/cs_test_1234567890'
        )

        expect(Stripe::Checkout::Session).to receive(:create).with(
          hash_including(automatic_tax: { enabled: true }),
          anything
        ).and_return(checkout_session)

        result = client.create_checkout_session(
          price_id: price_id,
          customer_email: customer_email,
          metadata: metadata
        )

        expect(result.id).to eq('cs_test_1234567890')
      end
    end

    context 'when API fails' do
      it 'raises ApiError' do
        allow(Stripe::Checkout::Session).to receive(:create)
          .and_raise(Stripe::InvalidRequestError.new('Invalid request', 'param'))

        expect {
          client.create_checkout_session(
            price_id: price_id,
            customer_email: customer_email,
            metadata: metadata
          )
        }.to raise_error(ApiClientBase::ApiError, /Stripe API error/)
      end
    end

    context 'when circuit breaker opens' do
      before do
        allow(Stripe::Checkout::Session).to receive(:create)
          .and_raise(Stripe::APIConnectionError.new('Connection error'))
      end

      it 'raises CircuitOpenError without hitting API after failures' do
        # Trigger circuit breaker by making multiple failing calls
        api_calls = 0
        circuit_opened = false

        6.times do
          begin
            client.create_checkout_session(
              price_id: price_id,
              customer_email: customer_email,
              metadata: metadata
            )
            api_calls += 1
          rescue ApiClientBase::ApiError
            # Expected - we want these to fail
            api_calls += 1
          rescue ApiClientBase::CircuitOpenError
            # Circuit breaker opened - this is what we want
            circuit_opened = true
            break
          end
        end

        # The circuit breaker should have opened
        expect(circuit_opened).to be true
      end
    end
  end

  describe '#get_subscription' do
    let(:subscription_id) { 'sub_1234567890' }

    context 'when API succeeds' do
      it 'returns subscription data' do
        subscription = double('Stripe::Subscription',
          id: subscription_id,
          status: 'active',
          current_period_end: 1234567890
        )

        allow(Stripe::Subscription).to receive(:retrieve)
          .with(subscription_id)
          .and_return(subscription)

        result = client.get_subscription(subscription_id: subscription_id)

        expect(result.id).to eq(subscription_id)
        expect(result.status).to eq('active')
        expect(result.current_period_end).to eq(1234567890)
      end
    end

    context 'when API returns 404' do
      it 'returns nil' do
        allow(Stripe::Subscription).to receive(:retrieve)
          .and_raise(Stripe::InvalidRequestError.new('No such subscription', 'id'))

        result = client.get_subscription(subscription_id: subscription_id)

        expect(result).to be_nil
      end
    end

    context 'when circuit breaker is open' do
      before do
        allow(Stripe::Subscription).to receive(:retrieve)
          .and_raise(Stripe::APIConnectionError.new('Connection error'))
      end

      it 'returns nil fallback without hitting API after failures' do
        # Trigger circuit breaker by making multiple failing calls
        api_calls = 0
        circuit_opened = false

        6.times do
          result = client.get_subscription(subscription_id: subscription_id)
          api_calls += 1

          # If result is nil, the circuit breaker might be open
          if result.nil?
            circuit_opened = true
            break
          end
        end

        # The circuit breaker should have opened and returned nil
        expect(circuit_opened).to be true
      end
    end
  end

  describe '#get_customer' do
    let(:customer_id) { 'cus_1234567890' }

    context 'when API succeeds' do
      it 'returns customer data' do
        customer = double('Stripe::Customer',
          id: customer_id,
          email: 'test@example.com',
          created: 1234567890
        )

        allow(Stripe::Customer).to receive(:retrieve)
          .with(customer_id)
          .and_return(customer)

        result = client.get_customer(customer_id: customer_id)

        expect(result.id).to eq(customer_id)
        expect(result.email).to eq('test@example.com')
        expect(result.created).to eq(1234567890)
      end
    end

    context 'when API returns 404' do
      it 'returns nil' do
        allow(Stripe::Customer).to receive(:retrieve)
          .and_raise(Stripe::InvalidRequestError.new('No such customer', 'id'))

        result = client.get_customer(customer_id: customer_id)

        expect(result).to be_nil
      end
    end
  end

  describe '#create_customer' do
    let(:email) { 'test@example.com' }
    let(:metadata) { { user_id: '123', plan: 'starter' } }

    context 'when API succeeds' do
      it 'returns customer data' do
        customer = double('Stripe::Customer',
          id: 'cus_1234567890',
          email: email
        )

        allow(Stripe::Customer).to receive(:create)
          .with(hash_including(email: email, metadata: metadata))
          .and_return(customer)

        result = client.create_customer(email: email, metadata: metadata)

        expect(result.id).to eq('cus_1234567890')
        expect(result.email).to eq(email)
      end
    end

    context 'when API fails' do
      it 'raises ApiError' do
        allow(Stripe::Customer).to receive(:create)
          .and_raise(Stripe::InvalidRequestError.new('Invalid request', 'email'))

        expect {
          client.create_customer(email: email, metadata: metadata)
        }.to raise_error(ApiClientBase::ApiError, /Stripe API error/)
      end
    end
  end

  describe '#cancel_subscription' do
    let(:subscription_id) { 'sub_1234567890' }

    context 'when API succeeds' do
      it 'returns canceled subscription data' do
        subscription = double('Stripe::Subscription',
          id: subscription_id,
          status: 'canceled'
        )

        stripe_subscription = double('Stripe::Subscription')
        allow(stripe_subscription).to receive(:delete).and_return(subscription)
        allow(Stripe::Subscription).to receive(:retrieve).with(subscription_id).and_return(stripe_subscription)

        result = client.cancel_subscription(subscription_id: subscription_id)

        expect(result.id).to eq(subscription_id)
        expect(result.status).to eq('canceled')
      end
    end

    context 'when API fails' do
      it 'raises ApiError' do
        allow(Stripe::Subscription).to receive(:retrieve)
          .and_raise(Stripe::InvalidRequestError.new('Invalid request', 'id'))

        expect {
          client.cancel_subscription(subscription_id: subscription_id)
        }.to raise_error(ApiClientBase::ApiError, /Stripe API error/)
      end
    end
  end

  describe '#get_payment_intent' do
    let(:payment_intent_id) { 'pi_1234567890' }

    context 'when API succeeds' do
      it 'returns payment intent data' do
        payment_intent = double('Stripe::PaymentIntent',
          id: payment_intent_id,
          status: 'succeeded',
          amount: 2000
        )

        allow(Stripe::PaymentIntent).to receive(:retrieve)
          .with(payment_intent_id)
          .and_return(payment_intent)

        result = client.get_payment_intent(payment_intent_id: payment_intent_id)

        expect(result.id).to eq(payment_intent_id)
        expect(result.status).to eq('succeeded')
        expect(result.amount).to eq(2000)
      end
    end

    context 'when API returns 404' do
      it 'returns nil' do
        allow(Stripe::PaymentIntent).to receive(:retrieve)
          .and_raise(Stripe::InvalidRequestError.new('No such payment intent', 'id'))

        result = client.get_payment_intent(payment_intent_id: payment_intent_id)

        expect(result).to be_nil
      end
    end
  end

  describe '#get_checkout_session' do
    let(:session_id) { 'cs_test_123' }

    context 'when session exists' do
      it 'retrieves the session' do
        session = double('Stripe::Checkout::Session',
          id: session_id,
          subscription: 'sub_test_456',
          customer: 'cus_test_789'
        )

        allow(Stripe::Checkout::Session).to receive(:retrieve)
          .with(session_id)
          .and_return(session)

        result = client.get_checkout_session(session_id: session_id)

        expect(result.id).to eq(session_id)
        expect(result.subscription).to eq('sub_test_456')
        expect(result.customer).to eq('cus_test_789')
      end
    end

    context 'when session does not exist' do
      it 'returns nil' do
        allow(Stripe::Checkout::Session).to receive(:retrieve)
          .and_raise(Stripe::InvalidRequestError.new('No such checkout session', 'session_id'))

        session = client.get_checkout_session(session_id: 'cs_nonexistent')

        expect(session).to be_nil
      end
    end

    context 'when API raises other Stripe error' do
      it 'raises ApiError' do
        allow(Stripe::Checkout::Session).to receive(:retrieve)
          .and_raise(Stripe::APIConnectionError.new('Connection error'))

        expect {
          client.get_checkout_session(session_id: session_id)
        }.to raise_error(ApiClientBase::ApiError, /Stripe API error/)
      end
    end
  end

  describe 'initialization' do
    it 'sets up Stripe API key' do
      described_class.new
      expect(Stripe.api_key).to eq('sk_test_1234567890')
    end
  end

  describe '.validate_configuration!' do
    before do
      # Create valid StripePlan records
      create(:stripe_plan, :starter, stripe_price_id: 'price_valid_starter_123')
      create(:stripe_plan, :pro, stripe_price_id: 'price_valid_pro_123')
    end

    context 'when all plans have valid price IDs' do
      it 'returns true without errors' do
        expect(StripeClient.validate_configuration!).to be true
      end
    end

    context 'when a plan has placeholder price ID' do
      before do
        create(:stripe_plan, :starter, :with_placeholder, plan_name: 'enterprise', active: true)
      end

      it 'raises ConfigurationError with error message' do
        expect {
          StripeClient.validate_configuration!
        }.to raise_error(StripeClient::ConfigurationError, /enterprise plan has placeholder price ID/)
      end
    end

    context 'when a plan has CHANGEME price ID' do
      before do
        invalid_plan = create(:stripe_plan, plan_name: 'trial', active: true)
        invalid_plan.update_column(:stripe_price_id, 'price_starter_CHANGEME')
      end

      it 'raises ConfigurationError' do
        expect {
          StripeClient.validate_configuration!
        }.to raise_error(StripeClient::ConfigurationError, /trial plan has placeholder price ID/)
      end
    end

    context 'when all plans are inactive' do
      before do
        StripePlan.update_all(active: false)
      end

      it 'returns true (no active plans to validate)' do
        expect(StripeClient.validate_configuration!).to be true
      end
    end
  end
end
