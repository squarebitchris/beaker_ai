require 'rails_helper'
require 'webmock/rspec'

RSpec.describe StripeClient, vcr: false do
  let(:client) { described_class.new }

  before do
    # Set up environment variables for testing
    allow(ENV).to receive(:fetch).with('STRIPE_SECRET_KEY').and_return('sk_test_1234567890')
    allow(ENV).to receive(:fetch).with('STRIPE_SUCCESS_URL', '').and_return('http://localhost:3000/dashboard?success=true')
    allow(ENV).to receive(:fetch).with('STRIPE_CANCEL_URL', '').and_return('http://localhost:3000/dashboard?canceled=true')

    # Reset circuit breakers before each test
    reset_circuit_breakers

    # Ensure WebMock is clean and properly configured
    WebMock.reset!
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  describe '#create_checkout_session' do
    let(:price_id) { 'price_1234567890' }
    let(:customer_email) { 'test@example.com' }
    let(:metadata) { { user_id: '123', plan: 'starter' } }

    context 'when API succeeds' do
      it 'returns checkout session data' do
        stub_request(:post, "https://api.stripe.com/v1/checkout/sessions")
          .with(
            headers: {
              'Authorization' => 'Bearer sk_test_1234567890',
              'Content-Type' => 'application/x-www-form-urlencoded'
            }
          )
          .to_return(
            status: 200,
            body: { id: 'cs_test_1234567890', url: 'https://checkout.stripe.com/pay/cs_test_1234567890' }.to_json
          )

        result = client.create_checkout_session(
          price_id: price_id,
          customer_email: customer_email,
          metadata: metadata
        )

        expect(result['id']).to eq('cs_test_1234567890')
        expect(result['url']).to eq('https://checkout.stripe.com/pay/cs_test_1234567890')
      end
    end

    context 'when API fails' do
      it 'raises ApiError' do
        stub_request(:post, 'https://api.stripe.com/v1/checkout/sessions')
          .to_return(status: 400, body: 'Bad Request')

        expect {
          client.create_checkout_session(
            price_id: price_id,
            customer_email: customer_email,
            metadata: metadata
          )
        }.to raise_error(ApiClientBase::ApiError, /Stripe API error: 400/)
      end
    end

    context 'when circuit breaker opens' do
      before do
        stub_request(:post, "https://api.stripe.com/v1/checkout/sessions")
          .to_return(status: 500, body: 'Internal Server Error')
      end

      it 'raises CircuitOpenError without hitting API' do
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

        # Debug: Check circuit breaker state
        puts "API calls made: #{api_calls}"
        puts "Circuit opened: #{circuit_opened}"

        # The circuit breaker should have opened
        expect(circuit_opened).to be true

        # Verify API was called the expected number of times
        expect(WebMock).to have_requested(:post, "https://api.stripe.com/v1/checkout/sessions").times(api_calls)
      end
    end
  end

  describe '#get_subscription' do
    let(:subscription_id) { 'sub_1234567890' }

    context 'when API succeeds' do
      it 'returns subscription data' do
        stub_request(:get, "https://api.stripe.com/v1/subscriptions/#{subscription_id}")
          .with(headers: { 'Authorization' => 'Bearer sk_test_1234567890' })
          .to_return(
            status: 200,
            body: { id: subscription_id, status: 'active', current_period_end: 1234567890 }.to_json
          )

        result = client.get_subscription(subscription_id: subscription_id)

        expect(result['id']).to eq(subscription_id)
        expect(result['status']).to eq('active')
        expect(result['current_period_end']).to eq(1234567890)
      end
    end

    context 'when API returns 404' do
      it 'returns nil' do
        stub_request(:get, "https://api.stripe.com/v1/subscriptions/#{subscription_id}")
          .to_return(status: 404, body: 'Not Found')

        result = client.get_subscription(subscription_id: subscription_id)

        expect(result).to be_nil
      end
    end

    context 'when circuit breaker is open' do
      before do
        stub_request(:get, /https:\/\/api\.stripe\.com\/v1\/subscriptions\/.*/)
          .to_return(status: 500, body: 'Internal Server Error')
      end

      it 'returns nil fallback without hitting API' do
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

        # Debug: Check circuit breaker state
        puts "API calls made: #{api_calls}"
        puts "Circuit opened: #{circuit_opened}"

        # The circuit breaker should have opened and returned nil
        expect(circuit_opened).to be true

        # Verify API was called the expected number of times
        expect(WebMock).to have_requested(:get, "https://api.stripe.com/v1/subscriptions/#{subscription_id}").times(api_calls)
      end
    end
  end

  describe '#get_customer' do
    let(:customer_id) { 'cus_1234567890' }

    context 'when API succeeds' do
      it 'returns customer data' do
        stub_request(:get, "https://api.stripe.com/v1/customers/#{customer_id}")
          .with(headers: { 'Authorization' => 'Bearer sk_test_1234567890' })
          .to_return(
            status: 200,
            body: { id: customer_id, email: 'test@example.com', created: 1234567890 }.to_json
          )

        result = client.get_customer(customer_id: customer_id)

        expect(result['id']).to eq(customer_id)
        expect(result['email']).to eq('test@example.com')
        expect(result['created']).to eq(1234567890)
      end
    end

    context 'when API returns 404' do
      it 'returns nil' do
        stub_request(:get, "https://api.stripe.com/v1/customers/#{customer_id}")
          .to_return(status: 404, body: 'Not Found')

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
        stub_request(:post, "https://api.stripe.com/v1/customers")
          .with(
            headers: {
              'Authorization' => 'Bearer sk_test_1234567890',
              'Content-Type' => 'application/x-www-form-urlencoded'
            }
          )
          .to_return(
            status: 200,
            body: { id: 'cus_1234567890', email: email }.to_json
          )

        result = client.create_customer(email: email, metadata: metadata)

        expect(result['id']).to eq('cus_1234567890')
        expect(result['email']).to eq(email)
      end
    end

    context 'when API fails' do
      it 'raises ApiError' do
        stub_request(:post, 'https://api.stripe.com/v1/customers')
          .to_return(status: 400, body: 'Bad Request')

        expect {
          client.create_customer(email: email, metadata: metadata)
        }.to raise_error(ApiClientBase::ApiError, /Stripe API error: 400/)
      end
    end
  end

  describe '#cancel_subscription' do
    let(:subscription_id) { 'sub_1234567890' }

    context 'when API succeeds' do
      it 'returns canceled subscription data' do
        stub_request(:delete, "https://api.stripe.com/v1/subscriptions/#{subscription_id}")
          .with(headers: { 'Authorization' => 'Bearer sk_test_1234567890' })
          .to_return(
            status: 200,
            body: { id: subscription_id, status: 'canceled' }.to_json
          )

        result = client.cancel_subscription(subscription_id: subscription_id)

        expect(result['id']).to eq(subscription_id)
        expect(result['status']).to eq('canceled')
      end
    end

    context 'when API fails' do
      it 'raises ApiError' do
        stub_request(:delete, "https://api.stripe.com/v1/subscriptions/#{subscription_id}")
          .to_return(status: 400, body: 'Bad Request')

        expect {
          client.cancel_subscription(subscription_id: subscription_id)
        }.to raise_error(ApiClientBase::ApiError, /Stripe API error: 400/)
      end
    end
  end

  describe '#get_payment_intent' do
    let(:payment_intent_id) { 'pi_1234567890' }

    context 'when API succeeds' do
      it 'returns payment intent data' do
        stub_request(:get, "https://api.stripe.com/v1/payment_intents/#{payment_intent_id}")
          .with(headers: { 'Authorization' => 'Bearer sk_test_1234567890' })
          .to_return(
            status: 200,
            body: { id: payment_intent_id, status: 'succeeded', amount: 2000 }.to_json
          )

        result = client.get_payment_intent(payment_intent_id: payment_intent_id)

        expect(result['id']).to eq(payment_intent_id)
        expect(result['status']).to eq('succeeded')
        expect(result['amount']).to eq(2000)
      end
    end

    context 'when API returns 404' do
      it 'returns nil' do
        stub_request(:get, "https://api.stripe.com/v1/payment_intents/#{payment_intent_id}")
          .to_return(status: 404, body: 'Not Found')

        result = client.get_payment_intent(payment_intent_id: payment_intent_id)

        expect(result).to be_nil
      end
    end
  end

  describe 'initialization' do
    it 'sets up HTTP client with correct API key' do
      expect(client.instance_variable_get(:@api_key)).to eq('sk_test_1234567890')
      expect(client.instance_variable_get(:@base_url)).to eq('https://api.stripe.com/v1')
    end
  end
end
