class CreatePosts < ActiveRecord::Migration[8.2]
  def change
    create_table :posts do |t|
      # Поля афиши как обычные колонки
      t.boolean  :is_afisha, default: false, null: false
      t.datetime :event_date
      t.integer  :event_duration, default: 1
      t.boolean  :manual_finished, default: false
      t.datetime :finished_at

      # Оставляем JSON только для того, что РЕАЛЬНО динамическое (например, теги или мелкие настройки)
      t.json :setting, default: {}, null: false
      t.json :tags_listing, default: {}, null: false

      t.timestamps
    end

    # Обычные, быстрые индексы
    add_index :posts, :is_afisha
    add_index :posts, :event_date
  end
end
