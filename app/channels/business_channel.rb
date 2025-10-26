# frozen_string_literal: true

class BusinessChannel < ApplicationCable::Channel
  def subscribed
    business = Business.find(params[:id])

    # Authorization: Only business owners can subscribe
    unless current_user && business.owners.include?(current_user)
      reject
      return
    end

    stream_for business
    Rails.logger.info("[BusinessChannel] User #{current_user.id} subscribed to business #{business.id}")
  end

  def unsubscribed
    # Cleanup when channel is unsubscribed
    Rails.logger.info("[BusinessChannel] User #{current_user&.id} unsubscribed from business #{params[:id]}")
  end

  # Class method to broadcast number assignment updates
  def self.broadcast_number_assigned(business)
    broadcast_replace_to(
      business,
      target: "business_number",
      partial: "businesses/number",
      locals: { business: business }
    )
    Rails.logger.info("[BusinessChannel] Broadcasted number assignment for business #{business.id}")
  rescue => e
    Rails.logger.error("[BusinessChannel] Broadcast failed: #{e.message}")
    Sentry.capture_exception(e, extra: { business_id: business.id })
  end
end
