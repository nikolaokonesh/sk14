class CreateSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :followable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
