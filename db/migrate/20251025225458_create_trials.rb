class CreateTrials < ActiveRecord::Migration[8.1]
  def change
    create_table :trials, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid, index: true
      
      # Persona data
      t.string :industry, null: false
      t.string :business_name, null: false
      t.string :scenario, null: false
      t.string :phone_e164, null: false
      
      # Vapi assistant
      t.string :vapi_assistant_id, index: true
      t.jsonb :assistant_config, default: {}
      
      # Trial limits
      t.integer :calls_used, default: 0, null: false
      t.integer :calls_limit, default: 3, null: false
      
      # Status tracking
      t.string :status, default: 'pending', null: false
      t.timestamp :expires_at, null: false
      
      t.timestamps
    end
    
    add_index :trials, :status
    add_index :trials, :expires_at
    add_index :trials, [:user_id, :created_at]
    add_check_constraint :trials, "calls_used <= calls_limit", name: "chk_calls_within_limit"
  end
end
