class CreateWebhookEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :webhook_events, id: :uuid do |t|
      t.string :provider, null: false  # stripe, twilio, vapi
      t.string :event_id, null: false  # Unique ID from provider
      t.string :event_type, null: false  # checkout.session.completed, call.ended, etc.
      t.jsonb :payload, null: false, default: {}
      t.string :status, default: 'pending', null: false  # pending, processing, completed, failed
      t.integer :retries, default: 0, null: false
      t.text :error_message
      t.timestamp :processed_at
      t.timestamps

      # Idempotency constraint: one event per provider+event_id
      t.index [ :provider, :event_id ], unique: true, name: 'idx_unique_webhook_event'

      t.index :provider
      t.index :event_type
      t.index :status
      t.index :created_at
    end
  end
end
