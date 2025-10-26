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
end
