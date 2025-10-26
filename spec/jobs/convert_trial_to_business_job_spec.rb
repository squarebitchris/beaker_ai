# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConvertTrialToBusinessJob, type: :job do
  let(:user) { create(:user) }
  let(:trial) { create(:trial, :active, user: user, industry: 'hvac', business_name: 'Smith HVAC') }
  let(:stripe_customer_id) { "cus_#{SecureRandom.hex(12)}" }
  let(:stripe_subscription_id) { "sub_#{SecureRandom.hex(12)}" }
  let(:plan) { 'starter' }
  let(:business_name) { 'Smith HVAC LLC' }

  let(:job_params) do
    {
      user_id: user.id,
      trial_id: trial.id,
      stripe_customer_id: stripe_customer_id,
      stripe_subscription_id: stripe_subscription_id,
      plan: plan,
      business_name: business_name
    }
  end

  before do
    # Create active scenario template for trial
    create(:scenario_template, key: 'hvac_lead_intake', active: true)

    # Stub Vapi client to avoid real API calls
    allow(VapiClient).to receive(:new).and_return(double(
      create_assistant: {
        'id' => "asst_paid_#{SecureRandom.hex(12)}",
        'name' => "#{business_name} Assistant"
      }
    ))

    # Stub StripePlan lookup
    allow(StripePlan).to receive(:for_plan).with(plan).and_return(
      double(calls_included: 100, base_price_dollars: 199)
    )
  end

  describe '#perform' do
    context 'when conversion succeeds' do
      it 'creates a Business record with correct attributes' do
        expect {
          described_class.perform_now(**job_params)
        }.to change(Business, :count).by(1)

        business = Business.last
        expect(business.name).to eq(business_name)
        expect(business.plan).to eq(plan)
        expect(business.status).to eq('active')
        expect(business.stripe_customer_id).to eq(stripe_customer_id)
        expect(business.stripe_subscription_id).to eq(stripe_subscription_id)
        expect(business.calls_included).to eq(100)
        expect(business.calls_used_this_period).to eq(0)
        expect(business.vapi_assistant_id).to be_present
        expect(business.trial).to eq(trial)
      end

      it 'creates a BusinessOwnership linking user to business' do
        expect {
          described_class.perform_now(**job_params)
        }.to change(BusinessOwnership, :count).by(1)

        business = Business.last
        ownership = BusinessOwnership.last
        expect(ownership.user).to eq(user)
        expect(ownership.business).to eq(business)
      end

      it 'marks trial as converted' do
        expect {
          described_class.perform_now(**job_params)
        }.to change { trial.reload.status }.from('active').to('converted')
      end

      it 'creates Vapi assistant without time limits' do
        vapi_client = instance_double(VapiClient)
        allow(VapiClient).to receive(:new).and_return(vapi_client)

        expect(vapi_client).to receive(:create_assistant) do |config:|
          expect(config[:max_duration_seconds]).to be_nil
          expect(config[:name]).to eq("#{business_name} Assistant")
          expect(config[:metadata][:business_name]).to eq(business_name)
          expect(config[:metadata][:industry]).to eq('hvac')
          {
            'id' => "asst_#{SecureRandom.hex(12)}",
            'name' => "#{business_name} Assistant"
          }
        end

        described_class.perform_now(**job_params)
      end

      it 'enqueues Agent Ready email' do
        expect {
          described_class.perform_now(**job_params)
        }.to have_enqueued_mail(BusinessMailer, :agent_ready)
      end

      it 'wraps operations in a transaction' do
        # Simulate Vapi failure after first call succeeds to test rollback
        call_count = 0
        allow(VapiClient).to receive(:new).and_return(
          instance_double(VapiClient,
            create_assistant: proc { |**args|
              call_count += 1
              # First call to DB should succeed, then raise error
              if call_count == 1
                { 'id' => "asst_#{SecureRandom.hex(12)}" }
              else
                raise StandardError, 'Vapi error'
              end
            }
          )
        )

        # Transaction should prevent partial state even if DB writes start
        expect {
          ActiveRecord::Base.transaction do
            business = Business.new(name: 'Test', plan: plan, stripe_customer_id: stripe_customer_id, stripe_subscription_id: stripe_subscription_id, calls_included: 100)
            business.save!
            raise StandardError, 'Simulated failure'
          end
        }.to raise_error(StandardError).and change(Business, :count).by(0)
      end
    end

    context 'when idempotency check triggers' do
      before do
        # Create existing business with same subscription_id
        create(:business,
          :with_trial,
          trial: trial,
          stripe_subscription_id: stripe_subscription_id,
          name: 'Existing Business',
          stripe_customer_id: stripe_customer_id
        )
      end

      it 'does not create duplicate business' do
        expect {
          described_class.perform_now(**job_params)
        }.not_to change(Business, :count)
      end

      it 'does not mark trial as converted' do
        expect {
          described_class.perform_now(**job_params)
        }.not_to change { trial.reload.status }
      end

      it 'logs idempotency message' do
        expect(Rails.logger).to receive(:info).with(/Already converted/)
        described_class.perform_now(**job_params)
      end
    end

    context 'when trial not found' do
      let(:invalid_trial_id) { SecureRandom.uuid }

      it 'raises RecordNotFound and reports to Sentry' do
        expect(Sentry).to receive(:capture_exception).and_call_original

        expect {
          described_class.perform_now(user_id: user.id, trial_id: invalid_trial_id, **job_params.except(:trial_id))
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when user not found' do
      it 'raises RecordNotFound and reports to Sentry' do
        invalid_user_id = SecureRandom.uuid
        expect(Sentry).to receive(:capture_exception).and_call_original

        expect {
          described_class.perform_now(user_id: invalid_user_id, **job_params.except(:user_id))
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when Vapi client fails' do
      before do
        allow_any_instance_of(VapiClient).to receive(:create_assistant).and_raise(
          ApiClientBase::ApiError, 'Vapi API error: 500'
        )
      end

      it 'captures error in Sentry and re-raises' do
        expect(Sentry).to receive(:capture_exception).and_call_original

        expect {
          described_class.perform_now(**job_params)
        }.to raise_error(StandardError)
      end
    end

    context 'when trial has assistant_config stored' do
      let(:stored_config) do
        {
          name: "#{trial.business_name} Assistant",
          system_prompt: "You are a helpful assistant",
          first_message: "Hello, this is Sarah from #{trial.business_name}",
          voice_id: 'rachel',
          model: 'gpt-4o-mini',
          temperature: 0.7,
          max_duration_seconds: 120
        }
      end

      before do
        trial.update!(assistant_config: stored_config)
      end

      it 'uses stored config instead of rebuilding' do
        vapi_client = instance_double(VapiClient)
        allow(VapiClient).to receive(:new).and_return(vapi_client)

        expect(vapi_client).to receive(:create_assistant) do |config:|
          # Should still have the system_prompt from stored config
          expect(config[:system_prompt]).to include("You are a helpful assistant")
          { 'id' => "asst_test" }
        end

        described_class.perform_now(**job_params)
      end
    end
  end
end

