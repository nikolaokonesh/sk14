class AddAfishaStatusToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :afisha_status, :string
    add_index :posts, :afisha_status
  end
end
