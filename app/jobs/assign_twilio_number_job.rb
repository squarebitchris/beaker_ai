# frozen_string_literal: true

class AssignTwilioNumberJob < ApplicationJob
  queue_as :default
  retry_on TwilioNumberUnavailable, wait: 5.minutes, attempts: 3
  retry_on StandardError, wait: 5.seconds, attempts: 5

  def perform(business_id, area_code: nil)
    business = Business.find(business_id)

    # Idempotency: exit early if already assigned
    return if business.phone_number.present?

    # Load with lock to prevent race conditions
    business.with_lock do
      # Double-check after acquiring lock
      return if business.phone_number.present?

      # Get area code from trial or fallback
      area_code ||= default_area_code(business)

      # Get Vapi assistant ID
      vapi_assistant_id = business.vapi_assistant_id
      unless vapi_assistant_id
        raise "Business #{business_id} has no vapi_assistant_id"
      end

      # Build voice URL for Vapi assistant
      voice_url = build_vapi_voice_url(business)

      # Purchase number with fallback strategy
      number_data = provision_with_fallback(area_code, voice_url)

      # Extract area code from purchased number
      purchased_area_code = area_code_from_e164(number_data["phone_number"])

      # Create PhoneNumber record
      phone_number = PhoneNumber.create!(
        business: business,
        e164: number_data["phone_number"],
        twilio_sid: number_data["sid"],
        area_code: purchased_area_code,
        country: "US"
      )

      Rails.logger.info("[AssignTwilioNumberJob] Assigned number #{phone_number.e164} to business #{business.id}")

      # Update Vapi assistant webhook URL to include business_id
      update_assistant_webhook_url(business)

      # Broadcast to BusinessChannel (if exists)
      BusinessChannel.broadcast_number_assigned(business) if defined?(BusinessChannel)

      # Send "Number Assigned" email
      begin
        BusinessMailer.number_assigned(business.id).deliver_later
      rescue => e
        Sentry.capture_exception(e, extra: { business_id: business.id })
        Rails.logger.error("[AssignTwilioNumberJob] Email failed: #{e.message}")
      end
    end

  rescue TwilioNumberUnavailable => e
    Rails.logger.warn("[AssignTwilioNumberJob] No numbers available for area code #{area_code}")
    Sentry.capture_message(
      "Twilio number unavailable",
      level: :warning,
      extra: { business_id: business_id, area_code: area_code, attempted_codes: @attempted_codes }
    )
    raise
  rescue => e
    Rails.logger.error("[AssignTwilioNumberJob] Failed for business #{business_id}: #{e.message}")
    Sentry.capture_exception(e, extra: { business_id: business_id, area_code: area_code })
    raise
  end

  private

  def default_area_code(business)
    # Try to extract from trial phone if available
    if business.trial&.phone_e164.present?
      # Extract area code from +1234567890 -> 234
      business.trial.phone_e164.gsub(/\D/, "").slice(1, 3)
    else
      "415" # Fallback to San Francisco
    end
  end

  def build_vapi_voice_url(business)
    # Custom webhook URL pointing to our app that processes incoming calls
    # This is the URL Twilio will POST to when receiving an inbound call
    base_url = ENV.fetch("APP_URL", "http://localhost:3000")
    "#{base_url}/webhooks/twilio/inbound?business_id=#{business.id}"
  end

  def provision_with_fallback(requested_area_code, voice_url)
    twilio_client = TwilioClient.new
    fallback_area_codes = [ "415", "510", "650" ]

    # Track attempted area codes for logging
    @attempted_codes = [ requested_area_code ] + fallback_area_codes

    # Try requested area code first
    begin
      Rails.logger.info("[AssignTwilioNumberJob] Attempting to provision number in area code #{ requested_area_code }")
      return twilio_client.provision_number(area_code: requested_area_code, voice_url: voice_url)
    rescue ApiClientBase::ApiError, StandardError => e
      Rails.logger.warn("[AssignTwilioNumberJob] Failed for #{requested_area_code}: #{e.message}")
    end

    # Try fallback area codes
    fallback_area_codes.each do |area_code|
      next if area_code == requested_area_code

      begin
        Rails.logger.info("[AssignTwilioNumberJob] Attempting to provision number in area code #{ area_code }")
        return twilio_client.provision_number(area_code: area_code, voice_url: voice_url)
      rescue ApiClientBase::ApiError, StandardError => e
        Rails.logger.warn("[AssignTwilioNumberJob] Failed for #{area_code}: #{e.message}")
      end
    end

    # All attempts failed
    raise TwilioNumberUnavailable, "No numbers available in any area code (#{@attempted_codes.join(', ')})"
  end

  def update_assistant_webhook_url(business)
    # Update Vapi assistant to use webhook URL that includes business_id for routing
    webhook_url = business.webhook_url_with_business_id

    VapiClient.new.update_assistant(
      assistant_id: business.vapi_assistant_id,
      config: {
        serverUrl: webhook_url
      }
    )

    Rails.logger.info("[AssignTwilioNumberJob] Updated assistant #{business.vapi_assistant_id} webhook to #{webhook_url}")
  rescue => e
    # Non-critical error - log but don't fail the job
    Rails.logger.error("[AssignTwilioNumberJob] Failed to update webhook URL: #{e.message}")
    Sentry.capture_exception(e, extra: { business_id: business.id })
  end

  def area_code_from_e164(e164)
    # Extract area code from E.164 format: +14155551234 -> 415
    e164.gsub(/\D/, "").slice(1, 3)
  end
end

# Custom exception for when Twilio has no numbers available
class TwilioNumberUnavailable < StandardError; end
