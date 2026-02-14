class CreateEntryKeywords < ActiveRecord::Migration[8.1]
  def change
    create_table :entry_keywords do |t|
      t.string :keyword
      t.references :entry, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true
      t.integer :frequency

      t.timestamps
    end
    add_index :entry_keywords, [ :keyword, :entry_id ], unique: true
  end
end
