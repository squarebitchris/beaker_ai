require 'rails_helper'

RSpec.describe 'Health Check', type: :request do
  describe 'GET /up' do
    it 'returns successful health status' do
      get '/up'

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to match(%r{application/json})

      json = JSON.parse(response.body)
      expect(json['status']).to eq('ok')
      expect(json['db']).to be true
      expect(json['queue']).to be true
    end
  end
end
