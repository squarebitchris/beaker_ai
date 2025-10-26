class VapiClient < ApiClientBase
  BASE_URL = "https://api.vapi.ai"

  def initialize
    @api_key = ENV.fetch("VAPI_API_KEY")
    @base_url = BASE_URL
  end

  def create_assistant(config:)
    with_circuit_breaker(name: "vapi:create_assistant") do
      with_retry(attempts: 3) do
        # Build full Vapi API payload structure
        payload = build_assistant_payload(config)

        response = make_request(:post, "/assistant", payload)

        raise ApiError, "Vapi API error: #{response.code}" unless (200..299).include?(response.code.to_i)

        JSON.parse(response.body)
      end
    end
  end

  def start_call(assistant_id:, phone_number:)
    with_circuit_breaker(name: "vapi:start_call") do
      with_retry(attempts: 3) do
        payload = {
          assistantId: assistant_id,
          phoneNumber: phone_number
        }

        response = make_request(:post, "/call", payload)

        raise ApiError, "Vapi API error: #{response.code}" unless (200..299).include?(response.code.to_i)

        JSON.parse(response.body)
      end
    end
  end

  def get_call(call_id:)
    with_circuit_breaker(name: "vapi:get_call", fallback: -> { nil }) do
      with_retry(attempts: 3) do
        response = make_request(:get, "/call/#{call_id}")

        return nil unless (200..299).include?(response.code.to_i)

        JSON.parse(response.body)
      end
    end
  end

  def update_assistant(assistant_id:, config:)
    with_circuit_breaker(name: "vapi:update_assistant") do
      with_retry(attempts: 3) do
        response = make_request(:patch, "/assistant/#{assistant_id}", config)

        raise ApiError, "Vapi API error: #{response.code}" unless (200..299).include?(response.code.to_i)

        JSON.parse(response.body)
      end
    end
  end

  def delete_assistant(assistant_id:)
    with_circuit_breaker(name: "vapi:delete_assistant") do
      with_retry(attempts: 3) do
        response = make_request(:delete, "/assistant/#{assistant_id}")

        raise ApiError, "Vapi API error: #{response.code}" unless (200..299).include?(response.code.to_i)

        true
      end
    end
  end

  private

  def build_assistant_payload(config)
    {
      name: config[:name],
      model: {
        provider: "openai",
        model: config[:model] || "gpt-4o-mini",
        temperature: config[:temperature] || 0.7,
        systemPrompt: config[:system_prompt]
      },
      voice: {
        provider: "11labs",
        voiceId: config[:voice_id] || "rachel"
      },
      firstMessage: config[:first_message],
      functions: config[:functions] || [],
      maxDurationSeconds: config[:max_duration_seconds] || 120,
      silenceTimeoutSeconds: config[:silence_timeout_seconds] || 30,
      serverUrl: config[:server_url] || "#{ENV.fetch('APP_URL', 'http://localhost:3000')}/webhooks/vapi"
    }.tap do |payload|
      # Add optional metadata if provided
      payload[:metadata] = config[:metadata] if config[:metadata]
    end
  end

  def make_request(method, path, payload = nil)
    uri = URI("#{@base_url}#{path}")

    case method
    when :get
      request = Net::HTTP::Get.new(uri)
    when :post
      request = Net::HTTP::Post.new(uri)
      request.body = payload.to_json if payload
    when :patch
      request = Net::HTTP::Patch.new(uri)
      request.body = payload.to_json if payload
    when :delete
      request = Net::HTTP::Delete.new(uri)
    end

    request["Authorization"] = "Bearer #{@api_key}"
    request["Content-Type"] = "application/json" if payload

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.request(request)
  end
end
