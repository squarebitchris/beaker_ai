class Admin::SearchController < Admin::BaseController
  def index
    @query = params[:q]&.strip
    return unless @query.present?

    @results = search_all_models(@query)
  end

  private

  def search_all_models(query)
    {
      businesses: search_businesses(query),
      users: search_users(query),
      trials: search_trials(query),
      calls: search_calls(query)
      # TODO: Add lead search when Lead model exists (Phase 5)
      # leads: search_leads(query)
    }
  end

  def search_businesses(query)
    Business.where(
      "name ILIKE ? OR stripe_customer_id ILIKE ?",
      "%#{query}%",
      "%#{query}%"
    ).includes(:owners).limit(10)
  end

  def search_users(query)
    normalized = normalize_email(query)
    User.where("email ILIKE ?", "%#{normalized}%")
        .includes(:trials, :businesses)
        .limit(10)
  end

  def search_trials(query)
    normalized_phone = normalize_phone(query)

    Trial.where(
      "phone_e164 ILIKE ? OR business_name ILIKE ?",
      "%#{normalized_phone}%",
      "%#{query}%"
    ).includes(:user).limit(10)
  end

  def search_calls(query)
    normalized_phone = normalize_phone(query)

    Call.where(
      "to_e164 ILIKE ? OR from_e164 ILIKE ? OR captured::text ILIKE ?",
      "%#{normalized_phone}%",
      "%#{normalized_phone}%",
      "%#{query}%"
    ).includes(:callable).limit(10)
  end

  def normalize_phone(phone)
    return phone if phone.blank?

    # Strip all non-digits
    digits = phone.to_s.gsub(/\D/, "")
    return "" if digits.blank?

    # Add +1 prefix if not present (US only for MVP)
    digits = "1#{digits}" unless digits.start_with?("1")

    # Return E.164 format
    "+#{digits}"
  end

  def normalize_email(email)
    return email if email.blank?

    # Lowercase, strip whitespace, remove +aliases
    email.to_s.strip.downcase.gsub(/\+.*@/, "@")
  end
end
