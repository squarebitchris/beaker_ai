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
      expect(mail.to).to eq([ user.email ])
    end

    it 'assigns @business' do
      expect(mail.body.encoded).to match(business.name)
    end

    it 'assigns @user' do
      # Check text part for user name (titleized from email)
      text_part = mail.parts.find { |p| p.content_type.include?('text/plain') }
      expect(text_part.body.decoded).to include(user.email.split('@').first.titleize)
    end

    context 'HTML email' do
      it 'includes plan information' do
        expect(mail.body.encoded).to match(business.plan.titleize)
      end

      it 'includes calls included count' do
        expect(mail.body.encoded).to match(business.calls_included.to_s)
      end

      it 'includes dashboard link' do
        html_part = mail.parts.find { |p| p.content_type.include?('text/html') }
        expect(html_part.body.decoded).to match(/beaker\.ai|localhost/)
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

    context 'email content validation' do
      it 'does not promise immediate phone number assignment' do
        # Phase 4 feature, should be marked "coming soon"
        expect(mail.body.encoded).to include('Coming Soon')
      end

      it 'includes current subscription status' do
        expect(mail.body.encoded).to match(/subscription.*active/i)
      end

      it 'clearly states what is available now vs later' do
        expect(mail.body.encoded).to match(/Active Right Now/i)
      end
    end

    context 'when StripePlan is not seeded' do
      before do
        allow(StripePlan).to receive(:for_plan).and_return(nil)
      end

      it 'still renders without errors' do
        expect { mail.body.encoded }.not_to raise_error
      end

      it 'shows fallback pricing' do
        expect(mail.body.encoded).to match(/\$199|\$499/)
      end
    end

    context 'mailer configuration' do
      it 'uses configured from address' do
        expect(mail.from).not_to include('from@example.com')
      end

      it 'has professional sender name' do
        # Should be "Beaker AI <...>" or configured MAILER_FROM
        expect(mail.from.first).to be_present
      end
    end
  end
end
