require 'rails_helper'

RSpec.describe 'Trials Controller', type: :request do
  describe 'routes' do
    it 'has all required routes' do
      expect(Rails.application.routes.recognize_path('/trials/new', method: :get)).to eq({ controller: 'trials', action: 'new' })
      expect(Rails.application.routes.recognize_path('/trials', method: :post)).to eq({ controller: 'trials', action: 'create' })
      expect(Rails.application.routes.recognize_path('/trials/123', method: :get)).to eq({ controller: 'trials', action: 'show', id: '123' })
      expect(Rails.application.routes.recognize_path('/trials/123/call', method: :post)).to eq({ controller: 'trials', action: 'call', id: '123' })
    end
  end

  describe 'authentication requirement' do
    it 'redirects unauthenticated users to sign in' do
      get new_trial_path
      expect(response).to redirect_to(new_user_session_path)

      post trials_path, params: { trial: { industry: 'hvac' } }
      expect(response).to redirect_to(new_user_session_path)

      get trial_path('123')
      expect(response).to redirect_to(new_user_session_path)

      post call_trial_path('123'), params: { phone_number: '+15555551234' }
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe 'Trial model methods' do
    let(:trial) { build(:trial) }

    it 'has all required methods' do
      expect(trial).to respond_to(:ready?)
      expect(trial).to respond_to(:expired?)
      expect(trial).to respond_to(:calls_remaining)
    end

    it 'ready? returns false for new trial' do
      expect(trial.ready?).to be false
    end

    it 'ready? returns true when vapi_assistant_id is present and status is active' do
      trial.vapi_assistant_id = 'asst_123'
      trial.status = 'active'
      expect(trial.ready?).to be true
    end
  end
end
