class CreateScenarioTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :scenario_templates, id: :uuid do |t|
      t.string :key, null: false
      t.integer :version, null: false
      t.boolean :active, default: true, null: false
      t.jsonb :prompt_pack, default: {}, null: false
      t.text :notes
      t.timestamps
    end

    add_index :scenario_templates, :key
    add_index :scenario_templates, [ :key, :active ], unique: true, where: "active = true", name: "idx_unique_active_scenario_template"
  end
end
