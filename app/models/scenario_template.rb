class ScenarioTemplate < ApplicationRecord
  has_many :trials, dependent: :nullify

  validates :key, presence: true
  validates :version, presence: true, numericality: { greater_than: 0 }
  validates :active, inclusion: { in: [ true, false ] }
  validates :prompt_pack, presence: true

  scope :active, -> { where(active: true) }

  def system_prompt
    prompt_pack["system"]
  end

  def first_message
    prompt_pack["first_message"]
  end

  def tools
    prompt_pack["tools"] || []
  end
end
