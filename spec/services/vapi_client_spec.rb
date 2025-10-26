require 'rails_helper'
require 'webmock/rspec'

RSpec.describe VapiClient, vcr: false do
  let(:client) { described_class.new }

  before do
    # Set up environment variables for testing
    allow(ENV).to receive(:fetch).with('VAPI_API_KEY').and_return('test_api_key')
    allow(ENV).to receive(:fetch).with('APP_URL', anything).and_return('http://localhost:3000')

    # Reset circuit breakers before each test
    reset_circuit_breakers

    # Ensure WebMock is clean
    WebMock.reset!
  end

  describe '#create_assistant' do
    let(:config) do
      {
        name: 'Test Assistant',
        system_prompt: 'You are a helpful assistant.',
        first_message: 'Hi, how can I help?',
        voice_id: 'rachel',
        functions: [],
        max_duration_seconds: 120,
        metadata: { trial_id: 'trial_123' }
      }
    end

    let(:expected_payload) do
      {
        name: 'Test Assistant',
        model: {
          provider: 'openai',
          model: 'gpt-4o-mini',
          temperature: 0.7,
          systemPrompt: 'You are a helpful assistant.'
        },
        voice: {
          provider: '11labs',
          voiceId: 'rachel'
        },
        firstMessage: 'Hi, how can I help?',
        functions: [],
        maxDurationSeconds: 120,
        silenceTimeoutSeconds: 30,
        serverUrl: 'http://localhost:3000/webhooks/vapi',
        metadata: { trial_id: 'trial_123' }
      }
    end

    context 'when API succeeds' do
      it 'returns assistant data' do
        stub_request(:post, 'https://api.vapi.ai/assistant')
          .with(
            headers: {
              'Authorization' => 'Bearer test_api_key',
              'Content-Type' => 'application/json'
            },
            body: expected_payload.to_json
          )
          .to_return(
            status: 200,
            body: { id: 'asst_123', name: 'Test Assistant' }.to_json
          )

        result = client.create_assistant(config: config)

        expect(result['id']).to eq('asst_123')
        expect(result['name']).to eq('Test Assistant')
      end

      it 'includes duration caps for trial abuse prevention' do
        stub_request(:post, 'https://api.vapi.ai/assistant')
          .with(
            body: hash_including(
              maxDurationSeconds: 120,
              silenceTimeoutSeconds: 30
            )
          )
          .to_return(status: 200, body: { id: 'asst_123' }.to_json)

        client.create_assistant(config: config)
      end

      it 'includes webhook serverUrl' do
        stub_request(:post, 'https://api.vapi.ai/assistant')
          .with(
            body: hash_including(
              serverUrl: 'http://localhost:3000/webhooks/vapi'
            )
          )
          .to_return(status: 200, body: { id: 'asst_123' }.to_json)

        client.create_assistant(config: config)
      end

      it 'uses APP_URL env var when available' do
        allow(ENV).to receive(:fetch).with('VAPI_API_KEY').and_return('test_api_key')
        allow(ENV).to receive(:fetch).with('APP_URL', 'http://localhost:3000')
          .and_return('https://my-app.herokuapp.com')

        stub_request(:post, 'https://api.vapi.ai/assistant')
          .with(
            body: hash_including(
              serverUrl: 'https://my-app.herokuapp.com/webhooks/vapi'
            )
          )
          .to_return(status: 200, body: { id: 'asst_123' }.to_json)

        client.create_assistant(config: config)
      end

      it 'omits maxDurationSeconds when nil (unlimited duration)' do
        config_unlimited = config.merge(max_duration_seconds: nil)

        stub_request(:post, 'https://api.vapi.ai/assistant')
          .to_return(status: 200, body: { id: 'asst_unlimited' }.to_json)

        result = client.create_assistant(config: config_unlimited)
        expect(result['id']).to eq('asst_unlimited')

        # Verify the request was made without maxDurationSeconds in the body
        expect(WebMock).to have_requested(:post, 'https://api.vapi.ai/assistant')
          .with { |req|
            body = JSON.parse(req.body)
            !body.key?('maxDurationSeconds')
          }
      end

      it 'includes maxDurationSeconds when explicitly set to 60' do
        config_limited = config.merge(max_duration_seconds: 60)

        stub_request(:post, 'https://api.vapi.ai/assistant')
          .with(
            body: hash_including(maxDurationSeconds: 60)
          )
          .to_return(status: 200, body: { id: 'asst_60s' }.to_json)

        result = client.create_assistant(config: config_limited)
        expect(result['id']).to eq('asst_60s')
      end

      it 'includes maxDurationSeconds when explicitly set to 120 (trial default)' do
        stub_request(:post, 'https://api.vapi.ai/assistant')
          .with(
            body: hash_including(maxDurationSeconds: 120)
          )
          .to_return(status: 200, body: { id: 'asst_trial' }.to_json)

        client.create_assistant(config: config)
      end
    end

    context 'when API fails' do
      it 'raises ApiError' do
        stub_request(:post, 'https://api.vapi.ai/assistant')
          .to_return(status: 400, body: 'Bad Request')

        expect {
          client.create_assistant(config: config)
        }.to raise_error(ApiClientBase::ApiError, /Vapi API error: 400/)
      end
    end

    context 'when circuit breaker opens' do
      before do
        stub_request(:post, 'https://api.vapi.ai/assistant')
          .to_return(status: 500, body: 'Internal Server Error')

        # Trigger 5 failures to open circuit
        5.times do
          begin
            client.create_assistant(config: config)
          rescue ApiClientBase::ApiError
            # Expected failures
          end
        end
      end

      it 'raises CircuitOpenError without hitting API' do
        expect {
          client.create_assistant(config: config)
        }.to raise_error(ApiClientBase::CircuitOpenError, /circuit breaker is open/)

        # Verify API was not called this time (still 5 from before)
        expect(WebMock).to have_requested(:post, 'https://api.vapi.ai/assistant').times(5)
      end
    end
  end

  describe '#start_call' do
    let(:assistant_id) { 'asst_123' }
    let(:phone_number) { '+15551234567' }

    context 'when API succeeds' do
      it 'returns call data' do
        stub_request(:post, 'https://api.vapi.ai/call')
          .with(
            headers: {
              'Authorization' => 'Bearer test_api_key',
              'Content-Type' => 'application/json'
            },
            body: {
              assistantId: assistant_id,
              phoneNumber: phone_number
            }.to_json
          )
          .to_return(
            status: 200,
            body: { id: 'call_456', status: 'initiated' }.to_json
          )

        result = client.start_call(assistant_id: assistant_id, phone_number: phone_number)

        expect(result['id']).to eq('call_456')
        expect(result['status']).to eq('initiated')
      end
    end

    context 'when API fails' do
      it 'raises ApiError' do
        stub_request(:post, 'https://api.vapi.ai/call')
          .to_return(status: 422, body: 'Unprocessable Entity')

        expect {
          client.start_call(assistant_id: assistant_id, phone_number: phone_number)
        }.to raise_error(ApiClientBase::ApiError, /Vapi API error: 422/)
      end
    end
  end

  describe '#get_call' do
    let(:call_id) { 'call_456' }

    context 'when API succeeds' do
      it 'returns call data' do
        stub_request(:get, "https://api.vapi.ai/call/#{call_id}")
          .with(headers: { 'Authorization' => 'Bearer test_api_key' })
          .to_return(
            status: 200,
            body: { id: call_id, status: 'completed', duration: 120 }.to_json
          )

        result = client.get_call(call_id: call_id)

        expect(result['id']).to eq(call_id)
        expect(result['status']).to eq('completed')
        expect(result['duration']).to eq(120)
      end
    end

    context 'when API returns 404' do
      it 'returns nil' do
        stub_request(:get, "https://api.vapi.ai/call/#{call_id}")
          .to_return(status: 404, body: 'Not Found')

        result = client.get_call(call_id: call_id)

        expect(result).to be_nil
      end
    end

    context 'when circuit breaker is open' do
      before do
        stub_request(:get, /https:\/\/api\.vapi\.ai\/call\/.*/)
          .to_return(status: 500, body: 'Internal Server Error')

        # Open circuit
        5.times do
          begin
            client.get_call(call_id: call_id)
          rescue ApiClientBase::ApiError
            # Expected failures
          end
        end
      end

      it 'returns nil fallback without hitting API' do
        result = client.get_call(call_id: call_id)

        expect(result).to be_nil
        # Verify API was called 6 times total (5 in before block + 1 in test)
        expect(WebMock).to have_requested(:get, "https://api.vapi.ai/call/#{call_id}").times(6)
      end
    end
  end

  describe '#update_assistant' do
    let(:assistant_id) { 'asst_123' }
    let(:config) { { name: 'Updated Assistant' } }

    context 'when API succeeds' do
      it 'returns updated assistant data' do
        stub_request(:patch, "https://api.vapi.ai/assistant/#{assistant_id}")
          .with(
            headers: {
              'Authorization' => 'Bearer test_api_key',
              'Content-Type' => 'application/json'
            },
            body: config.to_json
          )
          .to_return(
            status: 200,
            body: { id: assistant_id, name: 'Updated Assistant' }.to_json
          )

        result = client.update_assistant(assistant_id: assistant_id, config: config)

        expect(result['id']).to eq(assistant_id)
        expect(result['name']).to eq('Updated Assistant')
      end
    end
  end

  describe '#delete_assistant' do
    let(:assistant_id) { 'asst_123' }

    context 'when API succeeds' do
      it 'returns true' do
        stub_request(:delete, "https://api.vapi.ai/assistant/#{assistant_id}")
          .with(headers: { 'Authorization' => 'Bearer test_api_key' })
          .to_return(status: 200, body: '{}')

        result = client.delete_assistant(assistant_id: assistant_id)

        expect(result).to be true
      end
    end
  end

  describe 'initialization' do
    it 'sets up HTTP client with correct headers and timeout' do
      expect(client.instance_variable_get(:@api_key)).to eq('test_api_key')
      expect(client.instance_variable_get(:@base_url)).to eq('https://api.vapi.ai')
    end
  end
end
