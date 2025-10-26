class AddUniqueConstraintToStripeSubscriptionId < ActiveRecord::Migration[8.1]
  def change
    # Add unique index on stripe_subscription_id to prevent duplicate businesses
    # Use partial index to allow NULL values (businesses can exist without subscriptions)
    add_index :businesses, :stripe_subscription_id,
              unique: true,
              where: "stripe_subscription_id IS NOT NULL",
              name: 'idx_businesses_unique_stripe_subscription_id'
  end
end
