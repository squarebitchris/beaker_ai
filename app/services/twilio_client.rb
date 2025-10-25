class TwilioClient < ApiClientBase
  BASE_URL = 'https://api.twilio.com/2010-04-01'
  
  def initialize
    @account_sid = ENV.fetch('TWILIO_ACCOUNT_SID')
    @auth_token = ENV.fetch('TWILIO_AUTH_TOKEN')
    @http = HTTPX.with(
      headers: {
        'Authorization' => "Basic #{Base64.strict_encode64("#{@account_sid}:#{@auth_token}")}",
        'Content-Type' => 'application/x-www-form-urlencoded'
      }
    )
  end
  
  def make_call(to:, from:, url:)
    with_circuit_breaker(name: 'twilio:make_call') do
      with_retry(attempts: 3) do
        payload = {
          'To' => to,
          'From' => from,
          'Url' => url,
          'StatusCallback' => ENV.fetch('TWILIO_STATUS_CALLBACK_URL', ''),
          'StatusCallbackEvent' => ['initiated', 'ringing', 'answered', 'completed']
        }
        
        response = @http.post("#{BASE_URL}/Accounts/#{@account_sid}/Calls.json", form: payload)
        
        raise ApiError, "Twilio API error: #{response.status}" unless (200..299).include?(response.status)
        
        JSON.parse(response.body)
      end
    end
  end
  
  def get_call(call_sid:)
    with_circuit_breaker(name: 'twilio:get_call', fallback: -> { nil }) do
      with_retry(attempts: 3) do
        response = @http.get("#{BASE_URL}/Accounts/#{@account_sid}/Calls/#{call_sid}.json")
        
        return nil unless (200..299).include?(response.status)
        
        JSON.parse(response.body)
      end
    end
  end
  
  def provision_number(area_code: nil)
    with_circuit_breaker(name: 'twilio:provision_number') do
      with_retry(attempts: 3) do
        # First, search for available numbers
        search_params = { 'Country' => 'US' }
        search_params['AreaCode'] = area_code if area_code
        
        search_response = @http.get("#{BASE_URL}/Accounts/#{@account_sid}/AvailablePhoneNumbers/US/Local.json", params: search_params)
        
        raise ApiError, "Twilio search error: #{search_response.status}" unless search_response.status.success?
        
        available_numbers = JSON.parse(search_response.body)['available_phone_numbers']
        raise ApiError, 'No available numbers' if available_numbers.empty?
        
        # Purchase the first available number
        phone_number = available_numbers.first['phone_number']
        purchase_payload = {
          'PhoneNumber' => phone_number,
          'VoiceUrl' => ENV.fetch('TWILIO_VOICE_URL', '')
        }
        
        purchase_response = @http.post("#{BASE_URL}/Accounts/#{@account_sid}/IncomingPhoneNumbers.json", form: purchase_payload)
        
        raise ApiError, "Twilio purchase error: #{purchase_response.status}" unless purchase_response.status.success?
        
        JSON.parse(purchase_response.body)
      end
    end
  end
  
  def send_sms(to:, from:, body:)
    with_circuit_breaker(name: 'twilio:send_sms') do
      with_retry(attempts: 3) do
        payload = {
          'To' => to,
          'From' => from,
          'Body' => body
        }
        
        response = @http.post("#{BASE_URL}/Accounts/#{@account_sid}/Messages.json", form: payload)
        
        raise ApiError, "Twilio SMS error: #{response.status}" unless response.status.success?
        
        JSON.parse(response.body)
      end
    end
  end
end
