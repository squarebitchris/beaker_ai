# frozen_string_literal: true

require "rails_helper"

RSpec.describe Primitives::CardComponent, type: :component do
  it "renders card with content" do
    render_inline(described_class.new) do
      "Card content"
    end

    expect(page).to have_css("div.rounded-radius-lg.border")
    expect(page).to have_text("Card content")
  end

  it "renders card with title" do
    render_inline(described_class.new) do |card|
      card.with_title { "Card Title" }
      "Card content"
    end

    expect(page).to have_css("h3", text: "Card Title")
    expect(page).to have_text("Card content")
  end

  it "renders card with description" do
    render_inline(described_class.new) do |card|
      card.with_description { "Card description" }
      "Card content"
    end

    expect(page).to have_css("p.text-muted-foreground", text: "Card description")
  end

  it "renders card with title and description" do
    render_inline(described_class.new) do |card|
      card.with_title { "Title" }
      card.with_description { "Description" }
      "Content"
    end

    expect(page).to have_css("h3", text: "Title")
    expect(page).to have_css("p.text-muted-foreground", text: "Description")
    expect(page).to have_text("Content")
  end

  it "renders card with footer" do
    render_inline(described_class.new) do |card|
      card.with_footer { "Footer content" }
      "Card content"
    end

    expect(page).to have_text("Footer content")
    expect(page).to have_text("Card content")
  end

  it "renders card with custom header" do
    render_inline(described_class.new) do |card|
      card.with_header { "Custom header" }
      "Card content"
    end

    expect(page).to have_text("Custom header")
    expect(page).to have_text("Card content")
  end

  it "applies custom classes" do
    render_inline(described_class.new(class: "custom-class")) do
      "Content"
    end

    expect(page).to have_css("div.custom-class")
  end

  it "renders with all slots" do
    render_inline(described_class.new) do |card|
      card.with_title { "Title" }
      card.with_description { "Description" }
      card.with_footer { "Footer" }
      "Main content"
    end

    expect(page).to have_css("h3", text: "Title")
    expect(page).to have_css("p.text-muted-foreground", text: "Description")
    expect(page).to have_text("Main content")
    expect(page).to have_text("Footer")
  end
end
