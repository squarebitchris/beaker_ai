module AdminHelper
  # Mask email address showing only first character
  # Example: "john@example.com" -> "j***@example.com"
  def mask_email(email)
    return "***" if email.blank?

    parts = email.split("@")
    return email if parts.length != 2

    local = parts[0]
    domain = parts[1]

    return email if local.blank? || domain.blank?

    # Show first character of local part
    masked_local = "#{local[0]}***"
    "#{masked_local}@#{domain}"
  end

  # Mask phone number showing only last 4 digits
  # Example: "+15551234567" -> "***-***-4567"
  def mask_phone(phone)
    return "***" if phone.blank?

    # Extract all digits
    digits = phone.gsub(/\D/, "")
    return "***" if digits.length < 4

    # Show last 4 digits
    last_four = digits[-4..-1]
    "***-***-#{last_four}"
  end
end
