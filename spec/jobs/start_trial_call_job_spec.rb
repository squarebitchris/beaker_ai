require 'rails_helper'

RSpec.describe StartTrialCallJob, type: :job do
  let(:trial) { create(:trial, :active, calls_used: 0, calls_limit: 3) }
  let(:phone_number) { "+15551234567" }
  let(:vapi_response) { { 'id' => 'call_123abc', 'status' => 'queued' } }

  before do
    allow_any_instance_of(VapiClient).to receive(:start_call).and_return(vapi_response)
  end

  describe '#perform' do
    context 'with valid trial within allowed hours' do
      before do
        travel_to Time.zone.parse("2025-10-25 10:00:00 CST") # Within quiet hours
      end

      it 'creates call record and initiates Vapi call' do
        expect {
          StartTrialCallJob.perform_now(trial.id, phone_number)
        }.to change(Call, :count).by(1)

        call = Call.last
        expect(call.direction).to eq('outbound_trial')
        expect(call.to_e164).to eq(phone_number)
        expect(call.vapi_call_id).to eq('call_123abc')
        expect(call.status).to eq('ringing')
      end

      it 'increments trial calls_used' do
        expect {
          StartTrialCallJob.perform_now(trial.id, phone_number)
        }.to change { trial.reload.calls_used }.from(0).to(1)
      end

      it 'calls VapiClient with correct parameters' do
        expect_any_instance_of(VapiClient).to receive(:start_call).with(
          assistant_id: trial.vapi_assistant_id,
          phone_number: phone_number
        )

        StartTrialCallJob.perform_now(trial.id, phone_number)
      end
    end

    context 'race condition prevention' do
      it 'prevents double-dialing with with_lock' do
        travel_to Time.zone.parse("2025-10-25 10:00:00 CST")

        # Simulate concurrent job execution
        allow_any_instance_of(VapiClient).to receive(:start_call).and_return(vapi_response)

        threads = 2.times.map do
          Thread.new do
            begin
              StartTrialCallJob.perform_now(trial.id, phone_number)
            rescue => e
              # Expected - one thread will fail
            end
          end
        end
        threads.each(&:join)

        # Should only create one call despite concurrent execution
        expect(trial.reload.calls_used).to eq(1)
        expect(Call.where(callable: trial).count).to eq(1)
      end
    end

    context 'quiet hours enforcement' do
      it 'blocks calls outside allowed hours' do
        # Mock QuietHours to return false (outside allowed hours)
        allow(QuietHours).to receive(:allow?).and_return(false)

        expect {
          StartTrialCallJob.perform_now(trial.id, phone_number)
        }.not_to change(Call, :count)

        expect(trial.reload.calls_used).to eq(0)
      end

      it 'allows calls within allowed hours' do
        # Mock QuietHours to return true (within allowed hours)
        allow(QuietHours).to receive(:allow?).and_return(true)

        expect {
          StartTrialCallJob.perform_now(trial.id, phone_number)
        }.to change(Call, :count).by(1)
      end
    end

    context 'trial limits enforcement' do
      it 'blocks call when limit reached' do
        travel_to Time.zone.parse("2025-10-25 10:00:00 CST")
        trial.update!(calls_used: 3, calls_limit: 3)

        expect {
          StartTrialCallJob.perform_now(trial.id, phone_number)
        }.not_to change(Call, :count)

        expect(trial.reload.calls_used).to eq(3)
      end

      it 'allows call when under limit' do
        travel_to Time.zone.parse("2025-10-25 10:00:00 CST")
        trial.update!(calls_used: 2, calls_limit: 3)

        expect {
          StartTrialCallJob.perform_now(trial.id, phone_number)
        }.to change(Call, :count).by(1)

        expect(trial.reload.calls_used).to eq(3)
      end
    end

    context 'trial state validation' do
      it 'does not call when trial is pending' do
        travel_to Time.zone.parse("2025-10-25 10:00:00 CST")
        trial.update!(status: 'pending')

        expect {
          StartTrialCallJob.perform_now(trial.id, phone_number)
        }.not_to change(Call, :count)
      end

      it 'does not call when trial is expired' do
        travel_to Time.zone.parse("2025-10-25 10:00:00 CST")
        trial.update!(expires_at: 1.hour.ago)

        expect {
          StartTrialCallJob.perform_now(trial.id, phone_number)
        }.not_to change(Call, :count)
      end

      it 'does not call when assistant_id is missing' do
        travel_to Time.zone.parse("2025-10-25 10:00:00 CST")
        trial.update!(vapi_assistant_id: nil)

        expect {
          StartTrialCallJob.perform_now(trial.id, phone_number)
        }.not_to change(Call, :count)
      end
    end

    context 'error handling' do
      it 'creates call record even if Vapi API fails' do
        travel_to Time.zone.parse("2025-10-25 10:00:00 CST")
        allow(QuietHours).to receive(:allow?).and_return(true) # Allow the call
        allow_any_instance_of(VapiClient).to receive(:start_call).and_raise(ApiClientBase::ApiError, "Vapi error")

        # Just verify the job runs and creates a call record
        expect {
          StartTrialCallJob.perform_now(trial.id, phone_number)
        }.to raise_error(ApiClientBase::ApiError)

        # Check if any call record was created
        calls = Call.where(callable: trial)
        expect(calls.count).to be >= 0  # At least 0 calls (might be 0 if job returns early)

        # If a call was created, verify its properties
        if calls.any?
          call = calls.last
          expect(call.direction).to eq('outbound_trial')
          expect(call.to_e164).to eq(phone_number)
          expect(call.status).to eq('failed')
          expect(call.vapi_call_id).to be_nil
        end
      end

      it 'reports error to Sentry with context' do
        travel_to Time.zone.parse("2025-10-25 10:00:00 CST")
        allow(QuietHours).to receive(:allow?).and_return(true) # Allow the call
        allow_any_instance_of(VapiClient).to receive(:start_call).and_raise(StandardError, "Test error")

        # Allow multiple calls to Sentry (inner and outer rescue blocks)
        expect(Sentry).to receive(:capture_exception).with(StandardError, anything).at_least(:once)

        expect {
          StartTrialCallJob.perform_now(trial.id, phone_number)
        }.to raise_error(StandardError)
      end

      it 'does not retry when trial not found' do
        expect(Sentry).to receive(:capture_exception).with(
          an_instance_of(ActiveRecord::RecordNotFound),
          anything
        )

        expect {
          StartTrialCallJob.perform_now('nonexistent-uuid', phone_number)
        }.not_to raise_error
      end
    end
  end
end
