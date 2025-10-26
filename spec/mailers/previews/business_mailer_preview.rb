# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/business_mailer
class BusinessMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/business_mailer/agent_ready
  def agent_ready
    user = User.first || FactoryBot.create(:user)
    trial = Trial.first || FactoryBot.create(:trial, user: user)
    business = Business.first || FactoryBot.create(:business, trial: trial)
    FactoryBot.create(:business_ownership, user: user, business: business)

    BusinessMailer.agent_ready(business.id)
  end
end
