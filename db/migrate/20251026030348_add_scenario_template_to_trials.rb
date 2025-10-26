class AddScenarioTemplateToTrials < ActiveRecord::Migration[8.1]
  def change
    add_reference :trials, :scenario_template, type: :uuid, null: true, foreign_key: true
    add_column :trials, :ready_at, :timestamp
    add_index :trials, :ready_at
  end
end
