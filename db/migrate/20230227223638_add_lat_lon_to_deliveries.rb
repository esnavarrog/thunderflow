class AddLatLonToDeliveries < ActiveRecord::Migration[6.1]
  def change
    add_column :deliveries, :longitude, :string
    add_column :deliveries, :latitude, :string
  end
end
