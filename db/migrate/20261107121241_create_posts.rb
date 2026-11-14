class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.references :district, null: false, foreign_key: true
      t.references :category, foreign_key: true
      t.references :user, foreign_key: true

      t.string :post_type, null: false, default: "announcement"
      t.string :action_type

      t.datetime :published_at, null: false

      t.timestamps
    end

    add_index :posts, :post_type
    add_index :posts, :action_type
    add_index :posts, :published_at
    add_index :posts, [:district_id, :post_type, :published_at]
  end
end