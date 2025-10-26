require 'rails_helper'
require 'webmock/rspec'

RSpec.describe TwilioClient, vcr: false do
  let(:client) { described_class.new }

  before do
    # Set up environment variables for testing
    allow(ENV).to receive(:fetch).with('TWILIO_ACCOUNT_SID').and_return('test_account_sid')
    allow(ENV).to receive(:fetch).with('TWILIO_AUTH_TOKEN').and_return('test_auth_token')
    allow(ENV).to receive(:fetch).with('TWILIO_STATUS_CALLBACK_URL', '').and_return('http://localhost:3000/webhooks/twilio')
    allow(ENV).to receive(:fetch).with('TWILIO_VOICE_URL', '').and_return('http://localhost:3000/voice')

    # Reset circuit breakers before each test
    reset_circuit_breakers

    # Ensure WebMock is clean
    WebMock.reset!
  end

  describe '#make_call' do
    let(:to) { '+15551234567' }
    let(:from) { '+15557654321' }
    let(:url) { 'http://example.com/twiml' }

    context 'when API succeeds' do
      it 'returns call data' do
        stub_request(:post, 'https://api.twilio.com/2010-04-01/Accounts/test_account_sid/Calls.json')
          .with(
            headers: {
              'Authorization' => "Basic #{Base64.strict_encode64('test_account_sid:test_auth_token')}",
              'Content-Type' => 'application/x-www-form-urlencoded'
            }
          )
          .to_return(
            status: 201,
            body: { sid: 'CA1234567890', status: 'queued' }.to_json
          )

        result = client.make_call(to: to, from: from, url: url)

        expect(result['sid']).to eq('CA1234567890')
        expect(result['status']).to eq('queued')
      end
    end

    context 'when API fails' do
      it 'raises ApiError' do
        stub_request(:post, 'https://api.twilio.com/2010-04-01/Accounts/test_account_sid/Calls.json')
          .to_return(status: 400, body: 'Bad Request')

        expect {
          client.make_call(to: to, from: from, url: url)
        }.to raise_error(ApiClientBase::ApiError, /Twilio API error: 400/)
      end
    end

    context 'when circuit breaker opens' do
      before do
        stub_request(:post, 'https://api.twilio.com/2010-04-01/Accounts/test_account_sid/Calls.json')
          .to_return(status: 500, body: 'Internal Server Error')

        # Trigger 5 failures to open circuit
        5.times do
          begin
            client.make_call(to: to, from: from, url: url)
          rescue ApiClientBase::ApiError
            # Expected failures
          end
        end
      end

      it 'raises CircuitOpenError without hitting API' do
        expect {
          client.make_call(to: to, from: from, url: url)
        }.to raise_error(ApiClientBase::CircuitOpenError, /circuit breaker is open/)

        # Verify API was not called this time (still 5 from before)
        expect(WebMock).to have_requested(:post, 'https://api.twilio.com/2010-04-01/Accounts/test_account_sid/Calls.json').times(5)
      end
    end
  end

  describe '#get_call' do
    let(:call_sid) { 'CA1234567890' }

    context 'when API succeeds' do
      it 'returns call data' do
        stub_request(:get, "https://api.twilio.com/2010-04-01/Accounts/test_account_sid/Calls/#{call_sid}.json")
          .with(headers: {
            'Authorization' => "Basic #{Base64.strict_encode64('test_account_sid:test_auth_token')}"
          })
          .to_return(
            status: 200,
            body: { sid: call_sid, status: 'completed', duration: '120' }.to_json
          )

        result = client.get_call(call_sid: call_sid)

        expect(result['sid']).to eq(call_sid)
        expect(result['status']).to eq('completed')
        expect(result['duration']).to eq('120')
      end
    end

    context 'when API returns 404' do
      it 'returns nil' do
        stub_request(:get, "https://api.twilio.com/2010-04-01/Accounts/test_account_sid/Calls/#{call_sid}.json")
          .to_return(status: 404, body: 'Not Found')

        result = client.get_call(call_sid: call_sid)

        expect(result).to be_nil
      end
    end

    context 'when circuit breaker is open' do
      before do
        stub_request(:get, /https:\/\/api\.twilio\.com\/2010-04-01\/Accounts\/test_account_sid\/Calls\/.*\.json/)
          .to_return(status: 500, body: 'Internal Server Error')

        # Open circuit
        5.times do
          begin
            client.get_call(call_sid: call_sid)
          rescue ApiClientBase::ApiError
            # Expected failures
          end
        end
      end

      it 'returns nil fallback without hitting API' do
        result = client.get_call(call_sid: call_sid)

        expect(result).to be_nil
        # Verify API was called 6 times total (5 in before block + 1 in test)
        expect(WebMock).to have_requested(:get, "https://api.twilio.com/2010-04-01/Accounts/test_account_sid/Calls/#{call_sid}.json").times(6)
      end
    end
  end

  describe '#provision_number' do
    before do
      allow(ENV).to receive(:fetch).with('TWILIO_VOICE_URL', '').and_return('http://localhost:3000/webhooks/twilio/voice')
    end

    context 'when API succeeds' do
      it 'returns provisioned number data' do
        # Mock available numbers search
        stub_request(:get, 'https://api.twilio.com/2010-04-01/Accounts/test_account_sid/AvailablePhoneNumbers/US/Local.json')
          .with(query: { 'Country' => 'US' })
          .to_return(
            status: 200,
            body: {
              available_phone_numbers: [
                { phone_number: '+15551234567' }
              ]
            }.to_json
          )

        # Mock number purchase
        stub_request(:post, 'https://api.twilio.com/2010-04-01/Accounts/test_account_sid/IncomingPhoneNumbers.json')
          .with(
            headers: {
              'Authorization' => "Basic #{Base64.strict_encode64('test_account_sid:test_auth_token')}",
              'Content-Type' => 'application/x-www-form-urlencoded'
            }
          )
          .to_return(
            status: 201,
            body: { sid: 'PN1234567890', phone_number: '+15551234567' }.to_json
          )

        result = client.provision_number

        expect(result['sid']).to eq('PN1234567890')
        expect(result['phone_number']).to eq('+15551234567')
      end
    end

    context 'when no numbers available' do
      it 'raises ApiError' do
        stub_request(:get, 'https://api.twilio.com/2010-04-01/Accounts/test_account_sid/AvailablePhoneNumbers/US/Local.json')
          .with(query: { 'Country' => 'US' })
          .to_return(
            status: 200,
            body: { available_phone_numbers: [] }.to_json
          )

        expect {
          client.provision_number
        }.to raise_error(ApiClientBase::ApiError, /No available numbers/)
      end
    end
  end

  describe '#send_sms' do
    let(:to) { '+15551234567' }
    let(:from) { '+15557654321' }
    let(:body) { 'Test message' }

    context 'when API succeeds' do
      it 'returns SMS data' do
        stub_request(:post, 'https://api.twilio.com/2010-04-01/Accounts/test_account_sid/Messages.json')
          .with(
            headers: {
              'Authorization' => "Basic #{Base64.strict_encode64('test_account_sid:test_auth_token')}",
              'Content-Type' => 'application/x-www-form-urlencoded'
            },
            body: {
              'To' => to,
              'From' => from,
              'Body' => body
            }
          )
          .to_return(
            status: 201,
            body: { sid: 'SM1234567890', status: 'queued' }.to_json
          )

        result = client.send_sms(to: to, from: from, body: body)

        expect(result['sid']).to eq('SM1234567890')
        expect(result['status']).to eq('queued')
      end
    end

    context 'when API fails' do
      it 'raises ApiError' do
        stub_request(:post, 'https://api.twilio.com/2010-04-01/Accounts/test_account_sid/Messages.json')
          .to_return(status: 400, body: 'Bad Request')

        expect {
          client.send_sms(to: to, from: from, body: body)
        }.to raise_error(ApiClientBase::ApiError, /Twilio SMS error: 400/)
      end
    end
  end

  describe '#update_number_webhook' do
    let(:number_sid) { 'PN1234567890abcdef' }
    let(:voice_url) { 'https://example.com/voice' }

    before do
      allow(ENV).to receive(:fetch).with('TWILIO_STATUS_CALLBACK_URL', '').and_return('http://localhost:3000/webhooks/twilio')
    end

    context 'when update succeeds' do
      it 'updates voice URL and returns response' do
        stub_request(:post, "https://api.twilio.com/2010-04-01/Accounts/test_account_sid/IncomingPhoneNumbers/#{number_sid}.json")
          .with(
            headers: {
              'Authorization' => "Basic #{Base64.strict_encode64('test_account_sid:test_auth_token')}",
              'Content-Type' => 'application/x-www-form-urlencoded'
            }
          )
          .to_return(
            status: 200,
            body: { sid: number_sid, voice_url: voice_url }.to_json
          )

        result = client.update_number_webhook(number_sid: number_sid, voice_url: voice_url)

        expect(result['sid']).to eq(number_sid)
        expect(result['voice_url']).to eq(voice_url)
      end
    end

    context 'when update fails' do
      it 'raises ApiError' do
        stub_request(:post, /IncomingPhoneNumbers\/#{number_sid}\.json/)
          .to_return(status: 404, body: 'Not Found')

        expect {
          client.update_number_webhook(number_sid: number_sid, voice_url: voice_url)
        }.to raise_error(ApiClientBase::ApiError, /Twilio update error: 404/)
      end
    end
  end

  describe 'initialization' do
    it 'sets up HTTP client with correct credentials' do
      expect(client.instance_variable_get(:@account_sid)).to eq('test_account_sid')
      expect(client.instance_variable_get(:@auth_token)).to eq('test_auth_token')
      expect(client.instance_variable_get(:@base_url)).to eq('https://api.twilio.com/2010-04-01')
    end
  end
end
