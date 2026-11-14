class CreateClassifierKeywords < ActiveRecord::Migration[8.1]
  def change
    create_table :classifier_keywords do |t|
      t.string :kind, null: false
      t.string :value, null: false
      t.string :word, null: false
      t.integer :weight, default: 10

      t.timestamps
    end

    add_index :classifier_keywords, :word
    add_index :classifier_keywords, [:kind, :value]
    add_index :classifier_keywords, [:kind, :value, :word], unique: true, name: "idx_classifier_unique"
  end
end