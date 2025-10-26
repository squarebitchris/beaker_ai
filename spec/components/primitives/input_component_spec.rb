# frozen_string_literal: true

require "rails_helper"

RSpec.describe Primitives::InputComponent, type: :component do
  it "renders input with label" do
    render_inline(described_class.new(name: "email", label: "Email Address"))

    expect(page).to have_field("Email Address")
    expect(page).to have_css("input[name='email']")
  end

  it "renders input without label" do
    render_inline(described_class.new(name: "email"))

    expect(page).to have_css("input[name='email']")
    expect(page).not_to have_css("label")
  end

  it "shows required indicator" do
    render_inline(described_class.new(name: "email", label: "Email", required: true))

    expect(page).to have_css("span.text-destructive", text: "*")
  end

  it "displays helper text" do
    render_inline(described_class.new(
      name: "username",
      label: "Username",
      helper_text: "Choose a unique username"
    ))

    expect(page).to have_text("Choose a unique username")
    expect(page).to have_css("p.text-muted-foreground")
  end

  it "displays error message" do
    render_inline(described_class.new(
      name: "password",
      label: "Password",
      error: "Password is too short"
    ))

    expect(page).to have_text("Password is too short")
    expect(page).to have_css("p.text-destructive")
    expect(page).to have_css("input.border-destructive")
  end

  it "prioritizes error over helper text" do
    render_inline(described_class.new(
      name: "field",
      helper_text: "Helper text",
      error: "Error message"
    ))

    expect(page).to have_text("Error message")
    expect(page).not_to have_text("Helper text")
  end

  it "sets input type attribute" do
    render_inline(described_class.new(name: "email", type: "email"))

    expect(page).to have_css("input[type='email']")
  end

  it "sets placeholder attribute" do
    render_inline(described_class.new(name: "email", placeholder: "Enter your email"))

    expect(page).to have_css("input[placeholder='Enter your email']")
  end

  it "sets value attribute" do
    render_inline(described_class.new(name: "email", value: "test@example.com"))

    expect(page).to have_field("email", with: "test@example.com")
  end

  it "applies custom classes" do
    render_inline(described_class.new(name: "email", class: "custom-class"))

    expect(page).to have_css("input.custom-class")
  end

  it "sets aria-invalid when error is present" do
    render_inline(described_class.new(name: "email", error: "Invalid email"))

    expect(page).to have_css("input[aria-invalid='true']")
  end

  it "sets aria-describedby when helper text is present" do
    render_inline(described_class.new(
      name: "email",
      helper_text: "Enter a valid email"
    ))

    expect(page).to have_css("input[aria-describedby]")
  end
end
