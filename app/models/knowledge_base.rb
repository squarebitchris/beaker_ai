class KnowledgeBase < ApplicationRecord
  CATEGORIES = %w[pricing services hours faq general].freeze
  INDUSTRIES = %w[hvac gym dental].freeze

  validates :industry, presence: true, inclusion: { in: INDUSTRIES }
  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :content, presence: true
  validates :priority, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }
  scope :for_industry, ->(industry) { where(industry: industry.to_s) }
  scope :by_category, ->(category) { where(category: category.to_s) }
  scope :ordered, -> { order(priority: :desc, created_at: :asc) }

  # Convenience scope for getting KB entries for a specific industry
  scope :for_assistant, ->(industry) do
    active
      .for_industry(industry)
      .ordered
  end
end
