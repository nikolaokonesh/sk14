class CreateCategoryKeywords < ActiveRecord::Migration[8.1]
  def change
    create_table :category_keywords do |t|
      t.references :category, null: false, foreign_key: true
      t.string :word, null: false
      t.integer :weight, default: 1

      t.timestamps
    end

    add_index :category_keywords, :word
    add_index :category_keywords, [:category_id, :word], unique: true
  end
end