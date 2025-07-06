class AddDistanceToDeliveries < ActiveRecord::Migration[6.1]
  def change
    add_column :deliveries, :distance_meters, :bigint, default:100
  end
end
