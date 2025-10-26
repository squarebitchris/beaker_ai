# frozen_string_literal: true

require "rails_helper"

RSpec.describe Primitives::ButtonComponent, type: :component do
  it "renders with default variant and size" do
    render_inline(described_class.new) { "Click me" }

    expect(page).to have_button("Click me")
    expect(page).to have_css("button.bg-primary")
  end

  it "applies variant classes" do
    render_inline(described_class.new(variant: :destructive)) { "Delete" }

    expect(page).to have_button("Delete")
    expect(page).to have_css("button.bg-destructive")
  end

  it "applies size classes" do
    render_inline(described_class.new(size: :lg)) { "Large" }

    expect(page).to have_button("Large")
    expect(page).to have_css("button.h-14")
  end

  it "shows loading state" do
    render_inline(described_class.new(loading: true))

    expect(page).to have_css("svg.animate-spin")
    expect(page).to have_button(disabled: true)
    expect(page).to have_text("Loading...")
  end

  it "disables button when disabled attribute is true" do
    render_inline(described_class.new(disabled: true)) { "Disabled" }

    expect(page).to have_button("Disabled", disabled: true)
  end

  it "disables button when loading" do
    render_inline(described_class.new(loading: true))

    expect(page).to have_button(disabled: true)
  end

  it "applies custom classes" do
    render_inline(described_class.new(class: "w-full custom-class")) { "Submit" }

    expect(page).to have_css("button.w-full.custom-class")
  end

  it "sets button type attribute" do
    render_inline(described_class.new(type: "submit")) { "Submit" }

    expect(page).to have_css("button[type='submit']")
  end

  it "renders outline variant" do
    render_inline(described_class.new(variant: :outline)) { "Outline" }

    expect(page).to have_css("button.border")
  end

  it "renders ghost variant" do
    render_inline(described_class.new(variant: :ghost)) { "Ghost" }

    expect(page).to have_css("button.hover\\:bg-accent")
  end

  it "renders link variant" do
    render_inline(described_class.new(variant: :link)) { "Link" }

    expect(page).to have_css("button.underline-offset-4")
  end
end
