# frozen_string_literal: true

module Primitives
  class ToastComponent < ViewComponent::Base
    attr_reader :variant, :title, :message, :dismissible, :auto_dismiss, :html_options

    VARIANTS = {
      default: "bg-background border-border",
      success: "bg-background border-border text-foreground [&>svg]:text-green-600",
      error: "bg-destructive text-destructive-foreground border-destructive",
      warning: "bg-background border-border text-foreground [&>svg]:text-yellow-600"
    }.freeze

    ICONS = {
      success: "check_circle",
      error: "error",
      warning: "warning"
    }.freeze

    def initialize(variant: :default, title: nil, message: nil, dismissible: true, auto_dismiss: true, **html_options)
      @variant = variant.to_sym
      @title = title
      @message = message
      @dismissible = dismissible
      @auto_dismiss = auto_dismiss
      @html_options = html_options
    end

    def toast_classes
      base = "group pointer-events-auto relative flex w-full items-center justify-between space-x-4 overflow-hidden rounded-radius-md border p-4 pr-6 shadow-lg transition-all data-[swipe=cancel]:translate-x-0 data-[swipe=end]:translate-x-[var(--radix-toast-swipe-end-x)] data-[swipe=move]:translate-x-[var(--radix-toast-swipe-move-x)] data-[swipe=move]:transition-none data-[state=open]:animate-in data-[state=closed]:animate-out data-[swipe=end]:animate-out data-[state=closed]:fade-out-80 data-[state=closed]:slide-out-to-right-full data-[state=open]:slide-in-from-top-full data-[state=open]:sm:slide-in-from-bottom-full"

      [ base, VARIANTS[variant], html_options[:class] ].compact.join(" ")
    end

    def icon_name
      ICONS[variant]
    end

  def controller_attrs
    attrs = { data: { controller: "toast" } }
    attrs[:data][:"toast-auto-dismiss-value"] = auto_dismiss if auto_dismiss
    attrs
  end

  def render_icon(name)
    case name
    when "check_circle"
      tag.svg(class: "h-5 w-5", xmlns: "http://www.w3.org/2000/svg", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do
        tag.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z")
      end
    when "error"
      tag.svg(class: "h-5 w-5", xmlns: "http://www.w3.org/2000/svg", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do
        tag.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z")
      end
    when "warning"
      tag.svg(class: "h-5 w-5", xmlns: "http://www.w3.org/2000/svg", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do
        tag.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z")
      end
    end
  end
  end
end
