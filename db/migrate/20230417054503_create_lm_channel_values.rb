class CreateLmChannelValues < ActiveRecord::Migration[7.0]
  def change
    create_table :lm_channel_values do |t|
      t.string :value
      t.string :quality
      t.string :dt
      t.integer :lm_channel_id

      t.timestamps
    end
  end
end
