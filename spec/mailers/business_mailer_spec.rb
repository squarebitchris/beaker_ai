# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BusinessMailer, type: :mailer do
  describe '#agent_ready' do
    let(:user) { create(:user) }
    let(:trial) { create(:trial, user: user) }
    let(:business) { create(:business, trial: trial) }
    let(:ownership) { create(:business_ownership, user: user, business: business) }

    before do
      ownership # Ensure ownership is created
    end

    let(:mail) { described_class.agent_ready(business.id) }

    it 'renders the subject' do
      expect(mail.subject).to eq('Your AI Agent is Ready!')
    end

    it 'renders the sender email' do
      expect(mail.from).to be_present
    end

    it 'recipients are correct' do
      expect(mail.to).to eq([user.email])
    end

    it 'assigns @business' do
      expect(mail.body.encoded).to match(business.name)
    end

    it 'assigns @user' do
      expect(mail.body.decoded).to match(user.email.split('@').first)
    end

    context 'HTML email' do
      it 'includes plan information' do
        expect(mail.body.encoded).to match(business.plan.titleize)
      end

      it 'includes calls included count' do
        expect(mail.body.encoded).to match(business.calls_included.to_s)
      end

      it 'includes dashboard link' do
        expect(mail.body.decoded).to match(/beaker\.ai|localhost/)
      end
    end

    context 'when business has starter plan' do
      before do
        business.update!(plan: 'starter')
      end

      it 'shows starter plan in email' do
        expect(mail.body.encoded).to match(/Starter/)
      end
    end

    context 'when business has pro plan' do
      before do
        business.update!(plan: 'pro')
      end

      it 'shows pro plan in email' do
        expect(mail.body.encoded).to match(/Pro/)
      end
    end
  end
end

