class CreateCalls < ActiveRecord::Migration[8.1]
  def change
    create_table :calls, id: :uuid do |t|
      # Polymorphic owner (Trial or Business)
      t.references :callable, polymorphic: true, type: :uuid, null: false, index: true

      # Call metadata
      t.string :direction, null: false
      t.string :to_e164, null: false
      t.string :from_e164
      t.string :status, default: 'initiated', null: false

      # External IDs
      t.string :vapi_call_id, index: { unique: true, where: "vapi_call_id IS NOT NULL" }
      t.string :twilio_call_sid, index: { unique: true, where: "twilio_call_sid IS NOT NULL" }

      # Call outcome
      t.integer :duration_seconds
      t.text :transcript
      t.string :recording_url
      t.jsonb :extracted_lead, default: {}

      # Costs
      t.decimal :vapi_cost, precision: 8, scale: 4
      t.decimal :twilio_cost, precision: 8, scale: 4
      t.decimal :openai_cost, precision: 8, scale: 4

      t.timestamps
      t.timestamp :started_at
      t.timestamp :ended_at
    end

    add_index :calls, :direction
    add_index :calls, :status
    add_index :calls, [ :callable_type, :callable_id, :created_at ]
    add_index :calls, :created_at
  end
end
