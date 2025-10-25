class StripeClient < ApiClientBase
  BASE_URL = "https://api.stripe.com/v1"

  def initialize
    @api_key = ENV.fetch("STRIPE_SECRET_KEY")
    @base_url = BASE_URL
  end

  def create_checkout_session(price_id:, customer_email:, metadata: {})
    with_circuit_breaker(name: "stripe:create_checkout_session") do
      with_retry(attempts: 3) do
        payload = {
          "mode" => "subscription",
          "line_items[0][price]" => price_id,
          "line_items[0][quantity]" => 1,
          "customer_email" => customer_email,
          "success_url" => ENV.fetch("STRIPE_SUCCESS_URL", ""),
          "cancel_url" => ENV.fetch("STRIPE_CANCEL_URL", "")
        }

        # Add metadata if provided
        metadata.each_with_index do |(key, value), index|
          payload["metadata[#{key}]"] = value
        end

        response = make_request(:post, "/checkout/sessions", payload)

        raise ApiError, "Stripe API error: #{response.code}" unless (200..299).include?(response.code.to_i)

        JSON.parse(response.body)
      end
    end
  end

  def get_subscription(subscription_id:)
    with_circuit_breaker(name: "stripe:get_subscription", fallback: -> { nil }) do
      with_retry(attempts: 3) do
        response = make_request(:get, "/subscriptions/#{subscription_id}")

        return nil unless (200..299).include?(response.code.to_i)

        JSON.parse(response.body)
      end
    end
  end

  def get_customer(customer_id:)
    with_circuit_breaker(name: "stripe:get_customer", fallback: -> { nil }) do
      with_retry(attempts: 3) do
        response = make_request(:get, "/customers/#{customer_id}")

        return nil unless (200..299).include?(response.code.to_i)

        JSON.parse(response.body)
      end
    end
  end

  def create_customer(email:, metadata: {})
    with_circuit_breaker(name: "stripe:create_customer") do
      with_retry(attempts: 3) do
        payload = {
          "email" => email
        }

        # Add metadata if provided
        metadata.each_with_index do |(key, value), index|
          payload["metadata[#{key}]"] = value
        end

        response = make_request(:post, "/customers", payload)

        raise ApiError, "Stripe API error: #{response.code}" unless (200..299).include?(response.code.to_i)

        JSON.parse(response.body)
      end
    end
  end

  def cancel_subscription(subscription_id:)
    with_circuit_breaker(name: "stripe:cancel_subscription") do
      with_retry(attempts: 3) do
        response = make_request(:delete, "/subscriptions/#{subscription_id}")

        raise ApiError, "Stripe API error: #{response.code}" unless (200..299).include?(response.code.to_i)

        JSON.parse(response.body)
      end
    end
  end

  def get_payment_intent(payment_intent_id:)
    with_circuit_breaker(name: "stripe:get_payment_intent", fallback: -> { nil }) do
      with_retry(attempts: 3) do
        response = make_request(:get, "/payment_intents/#{payment_intent_id}")

        return nil unless (200..299).include?(response.code.to_i)

        JSON.parse(response.body)
      end
    end
  end

  private

  def make_request(method, path, payload = nil)
    uri = URI("#{@base_url}#{path}")

    case method
    when :get
      request = Net::HTTP::Get.new(uri)
    when :post
      request = Net::HTTP::Post.new(uri)
      request.body = URI.encode_www_form(payload) if payload
    when :delete
      request = Net::HTTP::Delete.new(uri)
    end

    request["Authorization"] = "Bearer #{@api_key}"
    request["Content-Type"] = "application/x-www-form-urlencoded" if payload

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.request(request)
  end
end
