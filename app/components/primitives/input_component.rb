# frozen_string_literal: true

module Primitives
  class InputComponent < ViewComponent::Base
    attr_reader :name, :type, :value, :label, :error, :helper_text, :placeholder, :required, :html_options

    def initialize(name:, type: "text", value: nil, label: nil, error: nil, helper_text: nil, placeholder: nil, required: false, **html_options)
      @name = name
      @type = type
      @value = value
      @label = label
      @error = error
      @helper_text = helper_text
      @placeholder = placeholder
      @required = required
      @html_options = html_options
    end

    def input_id
      html_options[:id] || "input-#{name.to_s.gsub(/[\[\]]/, '-')}"
    end

    def input_classes
      base = "flex h-11 min-h-[44px] w-full rounded-radius-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 transition-colors"

      error_classes = error ? "border-destructive focus-visible:ring-destructive" : ""

      [ base, error_classes, html_options[:class] ].compact.join(" ")
    end

    def label_classes
      base = "block text-sm font-medium mb-2"
      error_classes = error ? "text-destructive" : "text-foreground"

      [ base, error_classes ].compact.join(" ")
    end

    def helper_or_error_classes
      base = "mt-2 text-sm"

      if error
        "#{base} text-destructive"
      else
        "#{base} text-muted-foreground"
      end
    end

    def display_text
      error || helper_text
    end
  end
end
