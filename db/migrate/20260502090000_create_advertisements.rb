# frozen_string_literal: true

class CreateAdvertisements < ActiveRecord::Migration[8.2]
  def change
    create_table :advertisements do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, limit: 500
      t.integer :images_count, default: 0
      t.string :theme, null: false, default: "sunset"
      t.boolean :active, null: false, default: true
      t.boolean :top_placement, null: false, default: false
      t.datetime :paid_until

      t.timestamps
    end

    add_index :advertisements, :active
    add_index :advertisements, :created_at
    add_index :advertisements, :top_placement
    add_index :advertisements, :paid_until
  end
end
