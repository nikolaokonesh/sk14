class CreateReactions < ActiveRecord::Migration[8.1]
  def change
    create_table :reactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :entry, null: false, foreign_key: true
      t.string :content, null: false

      t.timestamps
    end

    add_index :reactions, [ :entry_id, :content ]
    add_index :reactions, [ :user_id, :entry_id, :content ], unique: true
  end
end
