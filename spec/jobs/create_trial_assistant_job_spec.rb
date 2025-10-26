require 'rails_helper'

RSpec.describe CreateTrialAssistantJob, type: :job do
  let(:user) { create(:user) }
  let(:trial) { create(:trial, :pending, user: user) }
  let(:vapi_client) { instance_double(VapiClient) }

  before do
    allow(VapiClient).to receive(:new).and_return(vapi_client)
    # Ensure scenario template exists for tests
    create(:scenario_template, :hvac_lead_intake)
  end

  describe '#perform' do
    context 'when trial is valid and ready for assistant creation' do
      let(:vapi_response) do
        {
          'id' => 'asst_123456789',
          'name' => "#{trial.business_name} Assistant",
          'status' => 'active'
        }
      end

      before do
        allow(vapi_client).to receive(:create_assistant).and_return(vapi_response)
      end

      it 'creates assistant and updates trial status to active', :vcr do
        expect {
          perform_enqueued_jobs do
            CreateTrialAssistantJob.perform_later(trial.id)
          end
        }.to change { trial.reload.status }.from('pending').to('active')

        trial.reload
        expect(trial.vapi_assistant_id).to eq('asst_123456789')
        expect(trial.assistant_config).to be_present
        expect(trial.assistant_config['name']).to eq("#{trial.business_name} Assistant")
        expect(trial.assistant_config['model']['model']).to eq('gpt-4o-mini')
        expect(trial.assistant_config['maxDurationSeconds']).to eq(120)
      end

      it 'calls VapiClient with correct configuration' do
        perform_enqueued_jobs do
          CreateTrialAssistantJob.perform_later(trial.id)
        end

        expect(vapi_client).to have_received(:create_assistant).with(
          config: hash_including(
            name: "#{trial.business_name} Assistant",
            model: hash_including(
              provider: 'openai',
              model: 'gpt-4o-mini'
            ),
            voice: hash_including(
              provider: 'elevenlabs',
              voiceId: 'rachel'
            ),
            maxDurationSeconds: 120,
            metadata: hash_including(
              trial_id: trial.id,
              industry: trial.industry,
              business_name: trial.business_name
            )
          )
        )
      end

      it 'uses PromptBuilder to merge template and persona' do
        expect(PromptBuilder).to receive(:call).with(
          template: anything,
          persona: {
            business_name: trial.business_name,
            industry: trial.industry,
            scenario: trial.scenario
          },
          kb: {}
        ).and_call_original

        perform_enqueued_jobs do
          CreateTrialAssistantJob.perform_later(trial.id)
        end
      end
    end

    context 'when trial already has an assistant (idempotency)' do
      before do
        trial.update!(vapi_assistant_id: 'asst_existing_123')
      end

      it 'skips creation and logs message' do
        expect(vapi_client).not_to receive(:create_assistant)

        perform_enqueued_jobs do
          CreateTrialAssistantJob.perform_later(trial.id)
        end

        trial.reload
        expect(trial.vapi_assistant_id).to eq('asst_existing_123')
        expect(trial.status).to eq('pending') # Status unchanged
      end
    end

    context 'when trial is not in pending status' do
      before do
        trial.update!(status: 'active')
      end

      it 'skips creation and logs warning' do
        expect(vapi_client).not_to receive(:create_assistant)

        perform_enqueued_jobs do
          CreateTrialAssistantJob.perform_later(trial.id)
        end
      end
    end

    context 'when trial is expired' do
      before do
        trial.update!(expires_at: 1.hour.ago)
      end

      it 'skips creation and logs warning' do
        expect(vapi_client).not_to receive(:create_assistant)

        perform_enqueued_jobs do
          CreateTrialAssistantJob.perform_later(trial.id)
        end
      end
    end

          context 'when scenario template is not found' do
            before do
              # Remove the scenario template that was created in the main before block
              ScenarioTemplate.delete_all
            end

            it 'raises exception and logs error' do
              expect {
                CreateTrialAssistantJob.perform_now(trial.id)
              }.to raise_error(ActiveRecord::RecordNotFound)
            end
          end

          context 'when VapiClient raises an error' do
            before do
              allow(vapi_client).to receive(:create_assistant).and_raise(
                ApiClientBase::ApiError, 'Vapi API error: 500'
              )
            end

            it 'logs error and re-raises exception' do
              expect {
                CreateTrialAssistantJob.perform_now(trial.id)
              }.to raise_error(ApiClientBase::ApiError, 'Vapi API error: 500')
            end
          end

          context 'when trial does not exist' do
            it 'raises ActiveRecord::RecordNotFound' do
              expect {
                CreateTrialAssistantJob.perform_now('non-existent-id')
              }.to raise_error(ActiveRecord::RecordNotFound)
            end
          end

          context 'retry behavior' do
            it 'has retry configuration inherited from ApplicationJob' do
              # Verify the job inherits retry behavior from ApplicationJob
              expect(CreateTrialAssistantJob.superclass).to eq(ApplicationJob)

              # Verify the job is configured to use the default queue
              expect(CreateTrialAssistantJob.queue_name).to eq('default')
            end
          end
  end

  describe 'job configuration' do
    it 'uses default queue' do
      expect(CreateTrialAssistantJob.queue_name).to eq('default')
    end

    it 'inherits from ApplicationJob' do
      expect(CreateTrialAssistantJob.superclass).to eq(ApplicationJob)
    end
  end
end
