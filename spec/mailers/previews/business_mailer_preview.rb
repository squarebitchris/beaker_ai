# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/business_mailer
class BusinessMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/business_mailer/agent_ready
  def agent_ready
    # Use real records if available, fallback to FactoryBot for clean dev environments
    user = User.first || FactoryBot.create(:user, email: 'demo@example.com')
    trial = user.trials.first || FactoryBot.create(:trial, :active, user: user)
    business = Business.first || FactoryBot.create(
      :business,
      name: 'Demo HVAC Company',
      plan: 'starter',
      trial: trial
    )

    # Ensure ownership exists
    unless business.owners.include?(user)
      FactoryBot.create(:business_ownership, user: user, business: business)
    end

    BusinessMailer.agent_ready(business.id)
  end

  # Preview pro plan variant
  def agent_ready_pro
    user = User.second || FactoryBot.create(:user, email: 'pro-demo@example.com')
    trial = user.trials.first || FactoryBot.create(:trial, :active, user: user)
    business = FactoryBot.create(
      :business,
      name: 'Pro HVAC Company',
      plan: 'pro',
      trial: trial,
      calls_included: 300
    )

    FactoryBot.create(:business_ownership, user: user, business: business) unless business.owners.include?(user)

    BusinessMailer.agent_ready(business.id)
  end
end
