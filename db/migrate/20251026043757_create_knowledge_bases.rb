class CreateKnowledgeBases < ActiveRecord::Migration[8.1]
  def change
    create_table :knowledge_bases, id: :uuid do |t|
      t.string :industry, null: false
      t.string :category, null: false  # pricing, services, hours, faq
      t.text :content, null: false
      t.integer :priority, default: 0, null: false  # For sorting importance
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :knowledge_bases, :industry
    add_index :knowledge_bases, [ :industry, :active ]
    add_index :knowledge_bases, [ :industry, :category, :priority ]
  end
end
