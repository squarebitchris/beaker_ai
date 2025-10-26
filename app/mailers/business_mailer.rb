# frozen_string_literal: true

class BusinessMailer < ApplicationMailer
  def agent_ready(business_id)
    @business = Business.find(business_id)
    @user = @business.owners.first

    mail(
      to: @user.email,
      subject: "Your AI Agent is Ready!"
    )
  end

  def number_assigned(business_id)
    @business = Business.find(business_id)
    @user = @business.owners.first
    @phone_number = @business.phone_number

    mail(
      to: @user.email,
      subject: "Your phone number is ready!"
    )
  end
end
