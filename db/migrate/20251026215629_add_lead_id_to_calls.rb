class AddLeadIdToCalls < ActiveRecord::Migration[8.1]
  def change
    add_reference :calls, :lead, null: true, foreign_key: false, type: :uuid, index: true
  end
end
