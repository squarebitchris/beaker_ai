# frozen_string_literal: true

module Primitives
  class CardComponent < ViewComponent::Base
    attr_reader :html_options

    renders_one :header
    renders_one :title
    renders_one :description
    renders_one :footer

    def initialize(**html_options)
      @html_options = html_options
    end

    def card_classes
      base = "rounded-radius-lg border border-border bg-card text-card-foreground shadow-sm"
      [ base, html_options[:class] ].compact.join(" ")
    end
  end
end
