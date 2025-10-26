require 'rails_helper'

RSpec.describe TrialReaperJob, type: :job do
  describe '#perform' do
    let!(:old_expired_trial) do
      create(:trial, status: 'expired', expires_at: 10.days.ago, created_at: 10.days.ago)
    end

    let!(:recent_expired_trial) do
      create(:trial, status: 'expired', expires_at: 5.days.ago, created_at: 5.days.ago)
    end

    let!(:converted_trial) do
      create(:trial, status: 'converted', expires_at: 10.days.ago, created_at: 10.days.ago)
    end

    let!(:active_trial) do
      create(:trial, status: 'active', expires_at: 1.day.from_now, created_at: 1.day.ago)
    end

    it 'deletes expired trials older than 7 days' do
      expect {
        TrialReaperJob.new.perform
      }.to change(Trial, :count).by(-1)

      expect(Trial.exists?(old_expired_trial.id)).to be false
      expect(Trial.exists?(recent_expired_trial.id)).to be true
      expect(Trial.exists?(converted_trial.id)).to be true
      expect(Trial.exists?(active_trial.id)).to be true
    end

    it 'does not delete converted trials even if expired' do
      TrialReaperJob.new.perform

      expect(Trial.exists?(converted_trial.id)).to be true
    end

    it 'does not delete recent expired trials (< 7 days)' do
      TrialReaperJob.new.perform

      expect(Trial.exists?(recent_expired_trial.id)).to be true
    end

    it 'does not delete active trials' do
      TrialReaperJob.new.perform

      expect(Trial.exists?(active_trial.id)).to be true
    end

    it 'logs the number of deleted trials' do
      expect(Rails.logger).to receive(:info).with(/Deleting 1 expired trials/)
      expect(Rails.logger).to receive(:info).with(/Cleanup complete. Deleted 1 trials/)

      TrialReaperJob.new.perform
    end

    context 'when deleting many trials' do
      before do
        # Create 101 old expired trials
        create_list(:trial, 101, status: 'expired', expires_at: 10.days.ago, created_at: 10.days.ago)
      end

      it 'sends Sentry alert for large cleanup' do
        expect(Sentry).to receive(:capture_message).with(
          /Large trial cleanup: 102 trials deleted/,
          hash_including(
            level: :warning,
            extra: hash_including(:cutoff_date, :deleted_count)
          )
        )

        TrialReaperJob.new.perform
      end
    end

    context 'when no trials need deletion' do
      before do
        # Delete the old expired trial
        old_expired_trial.destroy
      end

      it 'does not log cleanup messages' do
        expect(Rails.logger).not_to receive(:info).with(/Deleting/)

        TrialReaperJob.new.perform
      end

      it 'does not send Sentry alert' do
        expect(Sentry).not_to receive(:capture_message)

        TrialReaperJob.new.perform
      end
    end

    context 'with associated calls' do
      let!(:trial_with_calls) do
        create(:trial, status: 'expired', expires_at: 10.days.ago, created_at: 10.days.ago)
      end

      let!(:call1) { create(:call, callable: trial_with_calls) }
      let!(:call2) { create(:call, callable: trial_with_calls) }

      it 'deletes associated calls via cascade' do
        expect {
          TrialReaperJob.new.perform
        }.to change(Call, :count).by(-2)

        expect(Call.exists?(call1.id)).to be false
        expect(Call.exists?(call2.id)).to be false
      end
    end
  end

  describe 'job configuration' do
    it 'uses low priority queue' do
      expect(TrialReaperJob.queue_name).to eq('low')
    end

    it 'inherits from ApplicationJob' do
      expect(TrialReaperJob.superclass).to eq(ApplicationJob)
    end
  end
end
