class CreatePhoneNumbers < ActiveRecord::Migration[8.1]
  def change
    create_table :phone_numbers, id: :uuid do |t|
      t.references :business, type: :uuid, null: false, foreign_key: true, index: true
      t.string :e164, null: false
      t.string :twilio_sid, null: false
      t.string :country, default: 'US', null: false
      t.string :area_code
      t.jsonb :capabilities, default: {}
      t.timestamps

      t.index :e164, unique: true
      t.index :twilio_sid, unique: true
    end
  end
end
