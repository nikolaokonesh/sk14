class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.string   :title, limit: 200      # Запись части из :content
      t.datetime :premier                # Дата премьеры
      t.json     :setting                # Закрепленные посты, В топе, и прочие настройки

      t.timestamps
    end
  end
end
