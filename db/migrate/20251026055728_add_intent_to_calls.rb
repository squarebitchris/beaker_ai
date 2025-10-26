class AddIntentToCalls < ActiveRecord::Migration[8.1]
  def change
    add_column :calls, :intent, :string
    add_index :calls, :intent
  end
end
