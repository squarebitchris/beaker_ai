module Admin::WebhookEventsHelper
  def mask_pii_in_json(payload)
    return payload unless payload.is_a?(Hash)

    masked = payload.deep_dup
    mask_recursively(masked)
    masked
  end

  private

  def mask_recursively(obj)
    case obj
    when Hash
      obj.each do |key, value|
        if value.is_a?(String)
          obj[key] = mask_sensitive_value(key, value)
        else
          mask_recursively(value)
        end
      end
    when Array
      obj.each { |item| mask_recursively(item) }
    end
  end

  def mask_sensitive_value(key, value)
    key_str = key.to_s.downcase

    # Mask emails
    if key_str.include?("email") && value.match?(/@/)
      parts = value.split("@")
      if parts.length == 2
        local = parts[0]
        domain = parts[1]
        local_masked = "#{local[0]}***"
        domain_masked = "#{domain[0]}***"
        return "#{local_masked}@#{domain_masked}"
      end
      return value  # Invalid email format, return as-is
    end

    # Mask phone numbers
    if (key_str.include?("phone") || key_str.include?("e164")) && value.match?(/^\+\d/)
      return "***#{value.last(4)}"
    end

    value
  end
end
