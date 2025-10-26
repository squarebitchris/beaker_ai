# frozen_string_literal: true

require "rails_helper"

RSpec.describe Primitives::ToastComponent, type: :component do
  it "renders toast with title and message" do
    render_inline(described_class.new(
      title: "Success",
      message: "Your changes have been saved",
      auto_dismiss: false
    ))

    expect(page).to have_css("div.rounded-radius-md.border")
    expect(page).to have_text("Success")
    expect(page).to have_text("Your changes have been saved")
  end

  it "renders success variant with icon" do
    render_inline(described_class.new(
      variant: :success,
      title: "Success",
      auto_dismiss: false
    ))

    expect(page).to have_css("svg")
    expect(page).to have_text("Success")
  end

  it "renders error variant" do
    render_inline(described_class.new(
      variant: :error,
      title: "Error",
      message: "Something went wrong",
      auto_dismiss: false
    ))

    expect(page).to have_css("div.bg-destructive")
    expect(page).to have_text("Error")
  end

  it "renders warning variant" do
    render_inline(described_class.new(
      variant: :warning,
      title: "Warning",
      auto_dismiss: false
    ))

    expect(page).to have_text("Warning")
  end

  it "renders dismissible toast with close button" do
    render_inline(described_class.new(
      title: "Notification",
      dismissible: true,
      auto_dismiss: false
    ))

    expect(page).to have_css("button[data-action='click->toast#dismiss']")
  end

  it "renders non-dismissible toast without close button" do
    render_inline(described_class.new(
      title: "Processing",
      dismissible: false,
      auto_dismiss: false
    ))

    expect(page).not_to have_css("button[data-action='click->toast#dismiss']")
  end

  it "sets toast controller data attribute" do
    render_inline(described_class.new(
      title: "Notification",
      auto_dismiss: true
    ))

    expect(page).to have_css("div[data-controller='toast']")
    expect(page).to have_css("div[data-toast-auto-dismiss-value='true']")
  end

  it "renders with custom content" do
    render_inline(described_class.new(title: "Title", auto_dismiss: false)) do
      "Custom content"
    end

    expect(page).to have_text("Title")
    expect(page).to have_text("Custom content")
  end

  it "applies custom classes" do
    render_inline(described_class.new(
      title: "Notification",
      class: "custom-class",
      auto_dismiss: false
    ))

    expect(page).to have_css("div.custom-class")
  end
end
