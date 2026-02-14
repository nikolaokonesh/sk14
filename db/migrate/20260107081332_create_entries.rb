class CreateEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :entries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :entryable, polymorphic: true, null: false
      t.boolean  :trash, default: false  # Удаление поста в корзину
      t.datetime :trash_data             # Дата удаления
      t.string   :tags_list              # Список тэгов

      # Ссылка на родительскую Entry (самореферентная связь)
      # null: true, потому что у главных постов нет родителя.
      t.references :parent, foreign_key: { to_table: :entries }, index: true

      # Ссылка на корень всей ветки (обычно на Entry самого первого Поста)
      # Это позволит мгновенно достать всех participants и все комментарии темы
      t.references :root, foreign_key: { to_table: :entries }, index: true

      # Опционально: Тип вложенности или позиция для сортировки
      t.integer :position, default: 0

      t.timestamps
    end
  end
end
