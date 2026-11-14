class CreateDistricts < ActiveRecord::Migration[8.1]
  def change
    create_table :districts do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :emoji, default: "🏔️"
      t.string :time_zone, default: "Asia/Yakutsk" # 🆕 Часовой пояс
      t.integer :position, default: 0
      t.boolean :is_arctic, default: false
      
      t.timestamps
    end

    add_index :districts, :slug, unique: true
    add_index :districts, :position
  end
end