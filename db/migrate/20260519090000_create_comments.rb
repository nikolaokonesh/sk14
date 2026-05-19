# frozen_string_literal: true

class CreateComments < ActiveRecord::Migration[8.2]
  def change
    create_table :comments do |t|
      t.timestamps
    end
  end
end
