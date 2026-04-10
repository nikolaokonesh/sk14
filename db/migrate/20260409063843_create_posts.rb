class CreatePosts < ActiveRecord::Migration[8.2]
  def change
    create_table :posts do |t|
      t.datetime :premiera
      t.json :setting

      t.timestamps
    end
  end
end
