# frozen_string_literal: true

class CreateAdvertisements < ActiveRecord::Migration[8.2]
  def change
    create_table :advertisements do |t|
      t.string :theme, null: false, default: "sunset"
      t.boolean :active, null: false, default: true
      t.boolean :top_placement, null: false, default: false
      t.datetime :paid_until
      t.json :setting, null: false, default: {}

      t.timestamps
    end

    add_index :advertisements, :active
    add_index :advertisements, :created_at
    add_index :advertisements, :top_placement
    add_index :advertisements, :paid_until
    add_index :advertisements, "json_extract(setting, '$.no_comments')", name: "idx_advertisements_no_comments"
  end
end
