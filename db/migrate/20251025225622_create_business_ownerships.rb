class CreateBusinessOwnerships < ActiveRecord::Migration[8.1]
  def change
    create_table :business_ownerships, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid, index: true
      t.references :business, null: false, foreign_key: true, type: :uuid, index: true

      t.timestamps
    end

    add_index :business_ownerships, [ :user_id, :business_id ], unique: true
  end
end
