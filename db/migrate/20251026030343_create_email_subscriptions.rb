class CreateEmailSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :email_subscriptions, id: :uuid do |t|
      t.citext :email, null: false
      t.references :user, type: :uuid, null: true, foreign_key: true
      t.boolean :marketing_consent, default: false, null: false
      t.string :source, default: 'trial_signup', null: false
      t.timestamp :subscribed_at, null: false
      t.string :consent_ip
      t.text :consent_user_agent
      t.timestamps
    end

    add_index :email_subscriptions, :email, unique: true
    add_index :email_subscriptions, :source
    add_index :email_subscriptions, :subscribed_at
  end
end
