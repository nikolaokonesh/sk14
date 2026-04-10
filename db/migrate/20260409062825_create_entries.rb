class CreateEntries < ActiveRecord::Migration[8.2]
  def change
    create_table :entries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :entryable, polymorphic: true, null: false
      t.boolean  :trash, default: false
      t.datetime :trash_data
      t.references :parent, foreign_key: { to_table: :entries }, index: true
      t.references :root, foreign_key: { to_table: :entries }, index: true
      t.integer :position, default: 0
      t.integer :comments_count, default: 0, null: false
      t.timestamps
    end
  end
end
