class VapiClient < ApiClientBase
  BASE_URL = 'https://api.vapi.ai'
  
  def initialize
    @api_key = ENV.fetch('VAPI_API_KEY')
    @http = HTTPX.with(
      headers: {
        'Authorization' => "Bearer #{@api_key}",
        'Content-Type' => 'application/json'
      }
    )
  end
  
  def create_assistant(config:)
    with_circuit_breaker(name: 'vapi:create_assistant') do
      with_retry(attempts: 3) do
        response = @http.post("#{BASE_URL}/assistant", json: config)
        
        raise ApiError, "Vapi API error: #{response.status}" unless (200..299).include?(response.status)
        
        JSON.parse(response.body)
      end
    end
  end
  
  def start_call(assistant_id:, phone_number:)
    with_circuit_breaker(name: 'vapi:start_call') do
      with_retry(attempts: 3) do
        payload = {
          assistantId: assistant_id,
          phoneNumber: phone_number
        }
        
        response = @http.post("#{BASE_URL}/call", json: payload)
        
        raise ApiError, "Vapi API error: #{response.status}" unless (200..299).include?(response.status)
        
        JSON.parse(response.body)
      end
    end
  end
  
  def get_call(call_id:)
    with_circuit_breaker(name: 'vapi:get_call', fallback: -> { nil }) do
      with_retry(attempts: 3) do
        response = @http.get("#{BASE_URL}/call/#{call_id}")
        
        return nil unless (200..299).include?(response.status)
        
        JSON.parse(response.body)
      end
    end
  end
  
  def update_assistant(assistant_id:, config:)
    with_circuit_breaker(name: 'vapi:update_assistant') do
      with_retry(attempts: 3) do
        response = @http.patch("#{BASE_URL}/assistant/#{assistant_id}", json: config)
        
        raise ApiError, "Vapi API error: #{response.status}" unless (200..299).include?(response.status)
        
        JSON.parse(response.body)
      end
    end
  end
  
  def delete_assistant(assistant_id:)
    with_circuit_breaker(name: 'vapi:delete_assistant') do
      with_retry(attempts: 3) do
        response = @http.delete("#{BASE_URL}/assistant/#{assistant_id}")
        
        raise ApiError, "Vapi API error: #{response.status}" unless (200..299).include?(response.status)
        
        true
      end
    end
  end
end
