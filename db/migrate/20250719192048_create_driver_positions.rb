class CreateDriverPositions < ActiveRecord::Migration[7.2]
  def change
    create_table :driver_positions do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.float :latitude
      t.float :longitude
      t.float :destination_latitude
      t.float :destination_longitude

      t.timestamps
    end
  end
end
