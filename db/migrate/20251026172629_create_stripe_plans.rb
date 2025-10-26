class CreateStripePlans < ActiveRecord::Migration[8.1]
  def change
    create_table :stripe_plans, id: :uuid do |t|
      t.string :plan_name, null: false
      t.string :stripe_price_id, null: false
      t.integer :base_price_cents, null: false
      t.integer :calls_included, null: false
      t.integer :overage_cents_per_call, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :stripe_plans, :plan_name, unique: true
    add_index :stripe_plans, :stripe_price_id, unique: true
    add_index :stripe_plans, :active
  end
end
