require 'rails_helper'

RSpec.describe TrialChannel, type: :channel do
  let(:user) { create(:user) }
  let(:trial) { create(:trial, :active, user: user) }
  let(:other_user) { create(:user) }

  describe '#subscribed' do
    context 'when user owns the trial' do
      it 'successfully subscribes to the trial stream' do
        stub_connection(current_user: user)

        subscribe(id: trial.id)

        expect(subscription).to be_confirmed
        expect(subscription).to have_stream_for("trial:#{trial.id}")
      end
    end

    context 'when user does not own the trial' do
      it 'rejects the subscription' do
        stub_connection(current_user: other_user)

        subscribe(id: trial.id)

        expect(subscription).to be_rejected
      end
    end

    context 'when user is not authenticated' do
      it 'rejects the subscription' do
        stub_connection(current_user: nil)

        subscribe(id: trial.id)

        expect(subscription).to be_rejected
      end
    end

    context 'when trial does not exist' do
      it 'rejects the subscription' do
        stub_connection(current_user: user)

        subscribe(id: 'nonexistent-id')

        expect(subscription).to be_rejected
      end
    end
  end
end
