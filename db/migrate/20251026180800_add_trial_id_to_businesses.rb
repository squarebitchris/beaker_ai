class AddTrialIdToBusinesses < ActiveRecord::Migration[8.1]
  def change
    add_reference :businesses, :trial, null: true, foreign_key: true, type: :uuid
  end
end
