class CreatePosts < ActiveRecord::Migration[8.2]
  def change
    create_table :posts do |t|
      t.boolean  :is_afisha, default: false, null: false
      t.datetime :event_date
      t.integer  :event_duration, default: 1
      t.boolean  :manual_finished, default: false
      t.datetime :finished_at
      t.string   :afisha_status

      t.json :setting, default: {}, null: false
      t.json :tags_listing, default: {}, null: false

      t.timestamps
    end

    add_index :posts, :is_afisha
    add_index :posts, :event_date
    add_index :posts, :finished_at
    add_index :posts, :afisha_status
  end
end
