class PromptBuilder
  class MissingPlaceholderError < StandardError; end

  def self.call(template:, persona:, kb: {})
    new(template, persona, kb).call
  end

  def initialize(template, persona, kb = {})
    @template = deep_dup(template)
    @persona = deep_dup(persona)
    @kb = deep_dup(kb)
    @missing_placeholders = []
  end

  def call
    # Merge with precedence: template < kb < persona
    merged = deep_merge(@template, @kb)
    merged = deep_merge(merged, @persona)

    # Replace placeholders and track missing ones
    result = {
      system: replace_placeholders(merged["system"]),
      first_message: replace_placeholders(merged["first_message"]),
      tools: merged["tools"] || []
    }

    # Log warnings for missing placeholders but don't fail
    log_missing_placeholders if @missing_placeholders.any?

    result
  end

  private

  def deep_dup(obj)
    case obj
    when Hash
      obj.transform_keys(&:to_s).transform_values { |v| deep_dup(v) }
    when Array
      obj.map { |v| deep_dup(v) }
    else
      obj.duplicable? ? obj.dup : obj
    end
  end

  def deep_merge(base, override)
    result = base.dup
    override.each do |key, value|
      result[key.to_s] = if result[key.to_s].is_a?(Hash) && value.is_a?(Hash)
        deep_merge(result[key.to_s], value)
      else
        deep_dup(value)
      end
    end
    result
  end

  def replace_placeholders(text)
    return text unless text.is_a?(String)

    text.gsub(/\{\{(\w+)\}\}/) do |match|
      key = $1
      value = @persona[key]

      if value.nil?
        @missing_placeholders << key
        match # Leave placeholder unreplaced
      else
        value.to_s
      end
    end
  end

  def log_missing_placeholders
    Rails.logger.warn(
      "[PromptBuilder] Missing placeholder values: #{@missing_placeholders.join(', ')}"
    )
  end
end
