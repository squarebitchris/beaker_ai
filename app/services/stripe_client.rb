class StripeClient < ApiClientBase
  BASE_URL = 'https://api.stripe.com/v1'
  
  def initialize
    @api_key = ENV.fetch('STRIPE_SECRET_KEY')
    @http = HTTPX.with(
      headers: {
        'Authorization' => "Bearer #{@api_key}",
        'Content-Type' => 'application/x-www-form-urlencoded'
      }
    )
  end
  
  def create_checkout_session(price_id:, customer_email:, metadata: {})
    with_circuit_breaker(name: 'stripe:create_checkout_session') do
      with_retry(attempts: 3) do
        payload = {
          'mode' => 'subscription',
          'line_items[0][price]' => price_id,
          'line_items[0][quantity]' => 1,
          'customer_email' => customer_email,
          'success_url' => ENV.fetch('STRIPE_SUCCESS_URL', ''),
          'cancel_url' => ENV.fetch('STRIPE_CANCEL_URL', '')
        }
        
        # Add metadata if provided
        metadata.each_with_index do |(key, value), index|
          payload["metadata[#{key}]"] = value
        end
        
        response = @http.post("#{BASE_URL}/checkout/sessions", form: payload)
        
        raise ApiError, "Stripe API error: #{response.status}" unless (200..299).include?(response.status)
        
        JSON.parse(response.body)
      end
    end
  end
  
  def get_subscription(subscription_id:)
    with_circuit_breaker(name: 'stripe:get_subscription', fallback: -> { nil }) do
      with_retry(attempts: 3) do
        response = @http.get("#{BASE_URL}/subscriptions/#{subscription_id}")
        
        return nil unless (200..299).include?(response.status)
        
        JSON.parse(response.body)
      end
    end
  end
  
  def get_customer(customer_id:)
    with_circuit_breaker(name: 'stripe:get_customer', fallback: -> { nil }) do
      with_retry(attempts: 3) do
        response = @http.get("#{BASE_URL}/customers/#{customer_id}")
        
        return nil unless (200..299).include?(response.status)
        
        JSON.parse(response.body)
      end
    end
  end
  
  def create_customer(email:, metadata: {})
    with_circuit_breaker(name: 'stripe:create_customer') do
      with_retry(attempts: 3) do
        payload = {
          'email' => email
        }
        
        # Add metadata if provided
        metadata.each_with_index do |(key, value), index|
          payload["metadata[#{key}]"] = value
        end
        
        response = @http.post("#{BASE_URL}/customers", form: payload)
        
        raise ApiError, "Stripe API error: #{response.status}" unless (200..299).include?(response.status)
        
        JSON.parse(response.body)
      end
    end
  end
  
  def cancel_subscription(subscription_id:)
    with_circuit_breaker(name: 'stripe:cancel_subscription') do
      with_retry(attempts: 3) do
        response = @http.delete("#{BASE_URL}/subscriptions/#{subscription_id}")
        
        raise ApiError, "Stripe API error: #{response.status}" unless (200..299).include?(response.status)
        
        JSON.parse(response.body)
      end
    end
  end
  
  def get_payment_intent(payment_intent_id:)
    with_circuit_breaker(name: 'stripe:get_payment_intent', fallback: -> { nil }) do
      with_retry(attempts: 3) do
        response = @http.get("#{BASE_URL}/payment_intents/#{payment_intent_id}")
        
        return nil unless (200..299).include?(response.status)
        
        JSON.parse(response.body)
      end
    end
  end
end
