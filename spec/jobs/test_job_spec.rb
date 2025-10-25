require 'rails_helper'

RSpec.describe TestJob, type: :job do
  include ActiveJob::TestHelper
  
  describe '#perform' do
    it 'enqueues job in default queue' do
      expect {
        TestJob.perform_later('test message')
      }.to have_enqueued_job(TestJob)
        .with('test message')
        .on_queue('default')
    end
    
    it 'processes job successfully' do
      result = nil
      perform_enqueued_jobs do
        result = TestJob.perform_later('test message')
      end
      
      expect(result).to be_present
    end
    
    it 'logs job execution' do
      allow(Rails.logger).to receive(:info)
      
      perform_enqueued_jobs do
        TestJob.perform_later('test message')
      end
      
      expect(Rails.logger).to have_received(:info).with(/TestJob executing: test message/)
      expect(Rails.logger).to have_received(:info).with(/TestJob completed: test message/)
    end
  end
end
