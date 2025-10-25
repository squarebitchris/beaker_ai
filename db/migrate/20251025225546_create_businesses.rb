class CreateBusinesses < ActiveRecord::Migration[8.1]
  def change
    create_table :businesses, id: :uuid do |t|
      t.string :name, null: false

      # Stripe subscription
      t.string :stripe_customer_id, null: false, index: { unique: true }
      t.string :stripe_subscription_id, index: true
      t.string :status, default: 'active', null: false
      t.string :plan, null: false

      # Plan limits
      t.integer :calls_included, null: false
      t.integer :calls_used_this_period, default: 0, null: false

      # Vapi assistant (created on subscription)
      t.string :vapi_assistant_id, index: true

      t.timestamps
    end

    add_index :businesses, :status
    add_index :businesses, :plan
  end
end
