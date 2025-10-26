# frozen_string_literal: true

module Primitives
  class ButtonComponent < ViewComponent::Base
    attr_reader :variant, :size, :loading, :type, :disabled, :html_options

    VARIANTS = {
      default: "bg-primary text-primary-foreground hover:bg-primary/90",
      destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90",
      outline: "border border-input bg-background hover:bg-accent hover:text-accent-foreground",
      secondary: "bg-secondary text-secondary-foreground hover:bg-secondary/80",
      ghost: "hover:bg-accent hover:text-accent-foreground",
      link: "text-primary underline-offset-4 hover:underline"
    }.freeze

    SIZES = {
      sm: "h-9 px-3 text-sm",
      default: "h-11 px-4 py-2 min-h-[44px]",
      lg: "h-14 px-6 text-lg min-h-[56px]",
      icon: "h-10 w-10"
    }.freeze

    def initialize(variant: :default, size: :default, loading: false, type: "button", disabled: false, **html_options)
      @variant = variant.to_sym
      @size = size.to_sym
      @loading = loading
      @type = type
      @disabled = disabled || loading
      @html_options = html_options
    end

    def call
      button_tag(type: type, class: classes, disabled: disabled, **html_options) do
        if loading
          safe_join([ loading_spinner, " ", loading_text ])
        else
          content
        end
      end
    end

    private

    def classes
      base = "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-radius-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50"

      [ base, VARIANTS[variant], SIZES[size], html_options[:class] ].compact.join(" ")
    end

    def loading_spinner
      tag.svg(
        class: "animate-spin h-4 w-4",
        xmlns: "http://www.w3.org/2000/svg",
        fill: "none",
        viewBox: "0 0 24 24"
      ) do
        safe_join([
          tag.circle(
            class: "opacity-25",
            cx: "12",
            cy: "12",
            r: "10",
            stroke: "currentColor",
            stroke_width: "4"
          ),
          tag.path(
            class: "opacity-75",
            fill: "currentColor",
            d: "M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
          )
        ])
      end
    end

    def loading_text
      "Loading..."
    end
  end
end
