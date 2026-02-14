class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :otp_secret
      t.string :first_name
      t.string :last_name
      t.string :slug
      t.integer :followers_count, default: 0

      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :slug,  unique: true
  end
end
