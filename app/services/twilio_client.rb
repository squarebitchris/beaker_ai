class TwilioClient < ApiClientBase
  BASE_URL = "https://api.twilio.com/2010-04-01"

  def initialize
    @account_sid = ENV.fetch("TWILIO_ACCOUNT_SID")
    @auth_token = ENV.fetch("TWILIO_AUTH_TOKEN")
    @base_url = BASE_URL
  end

  def make_call(to:, from:, url:)
    with_circuit_breaker(name: "twilio:make_call") do
      with_retry(attempts: 3) do
        payload = {
          "To" => to,
          "From" => from,
          "Url" => url,
          "StatusCallback" => ENV.fetch("TWILIO_STATUS_CALLBACK_URL", ""),
          "StatusCallbackEvent" => [ "initiated", "ringing", "answered", "completed" ]
        }

        response = make_request(:post, "/Accounts/#{@account_sid}/Calls.json", payload)

        raise ApiError, "Twilio API error: #{response.code}" unless (200..299).include?(response.code.to_i)

        JSON.parse(response.body)
      end
    end
  end

  def get_call(call_sid:)
    with_circuit_breaker(name: "twilio:get_call", fallback: -> { nil }) do
      with_retry(attempts: 3) do
        response = make_request(:get, "/Accounts/#{@account_sid}/Calls/#{call_sid}.json")

        return nil unless (200..299).include?(response.code.to_i)

        JSON.parse(response.body)
      end
    end
  end

  def provision_number(area_code: nil, voice_url: nil)
    with_circuit_breaker(name: "twilio:provision_number") do
      with_retry(attempts: 3) do
        # First, search for available numbers
        search_params = { "Country" => "US" }
        search_params["AreaCode"] = area_code if area_code

        search_response = make_request(:get, "/Accounts/#{@account_sid}/AvailablePhoneNumbers/US/Local.json", search_params)

        raise ApiError, "Twilio search error: #{search_response.code}" unless (200..299).include?(search_response.code.to_i)

        available_numbers = JSON.parse(search_response.body)["available_phone_numbers"]
        raise ApiError, "No available numbers" if available_numbers.empty?

        # Purchase the first available number
        phone_number = available_numbers.first["phone_number"]
        purchase_payload = {
          "PhoneNumber" => phone_number,
          "VoiceUrl" => voice_url || ENV.fetch("TWILIO_VOICE_URL", "")
        }

        purchase_response = make_request(:post, "/Accounts/#{@account_sid}/IncomingPhoneNumbers.json", purchase_payload)

        raise ApiError, "Twilio purchase error: #{purchase_response.code}" unless (200..299).include?(purchase_response.code.to_i)

        JSON.parse(purchase_response.body)
      end
    end
  end

  def send_sms(to:, from:, body:)
    with_circuit_breaker(name: "twilio:send_sms") do
      with_retry(attempts: 3) do
        payload = {
          "To" => to,
          "From" => from,
          "Body" => body
        }

        response = make_request(:post, "/Accounts/#{@account_sid}/Messages.json", payload)

        raise ApiError, "Twilio SMS error: #{response.code}" unless (200..299).include?(response.code.to_i)

        JSON.parse(response.body)
      end
    end
  end

  def update_number_webhook(number_sid:, voice_url:)
    with_circuit_breaker(name: "twilio:update_number_webhook") do
      with_retry(attempts: 3) do
        payload = {
          "VoiceUrl" => voice_url,
          "VoiceMethod" => "POST",
          "StatusCallback" => ENV.fetch("TWILIO_STATUS_CALLBACK_URL", ""),
          "StatusCallbackMethod" => "POST"
        }

        response = make_request(:post, "/Accounts/#{@account_sid}/IncomingPhoneNumbers/#{number_sid}.json", payload)

        raise ApiError, "Twilio update error: #{response.code}" unless (200..299).include?(response.code.to_i)

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
      if payload
        uri.query = URI.encode_www_form(payload)
        request = Net::HTTP::Get.new(uri)
      end
    when :post
      request = Net::HTTP::Post.new(uri)
      request.body = URI.encode_www_form(payload) if payload
    end

    request["Authorization"] = "Basic #{Base64.strict_encode64("#{@account_sid}:#{@auth_token}")}"
    request["Content-Type"] = "application/x-www-form-urlencoded" if payload

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.request(request)
  end
end
