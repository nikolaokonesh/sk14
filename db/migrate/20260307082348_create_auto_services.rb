class CreateAutoServices < ActiveRecord::Migration[8.1]
  def change
    create_table :auto_services do |t|
      t.json :service_kinds, default: [], null: false
      t.string :car_brand, null: false
      t.string :plate_number, null: false
      t.string :phone, null: false
      t.integer :city_trip_price
      t.string :schedule_mode, default: "always", null: false
      t.string :work_days
      t.string :work_from
      t.string :work_to

      t.string :activity_state, null: false, default: "off"
      t.datetime :activated_at
      t.boolean :available_snapshot, null: false, default: false
      t.boolean :active, default: false, null: false
      t.text :notes

      t.timestamps
    end

    add_index :auto_services, :activity_state
    add_index :auto_services, :activated_at
  end
end
