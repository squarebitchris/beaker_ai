# frozen_string_literal: true

class PrimitivesPreview < ViewComponent::Preview
  # @label Button - All Variants
  def buttons
    render_with_template
  end

  # @label Button - Loading State
  def button_loading
    render_with_template
  end

  # @label Input - All States
  def inputs
    render_with_template
  end

  # @label Card - With Slots
  def cards
    render_with_template
  end

  # @label Toast - All Variants
  def toasts
    render_with_template
  end

  layout "component_preview"
end
