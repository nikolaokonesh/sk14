class CreateEntryReadStates < ActiveRecord::Migration[8.1]
  def change
    create_table :entry_read_states do |t|
      t.references :user, null: false, foreign_key: true
      t.references :entry, null: false, foreign_key: true
      t.datetime :post_read_at
      t.datetime :comments_read_at

      t.timestamps
    end

    add_index :entry_read_states, [ :user_id, :entry_id ], unique: true
  end
end
