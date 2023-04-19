class CreateLmChannels < ActiveRecord::Migration[7.0]
  def change
    create_table :lm_channels do |t|
      t.string :name
      t.integer :number
      t.string :prefix
      t.string :description
      t.boolean :active
      # LmChannelValue создает при каждом обновлении
      t.string :value
      t.string :quality
      t.string :dt
      t.string :slug

      t.timestamps
    end
    add_index :lm_channels, :slug, unique: true
  end
end
