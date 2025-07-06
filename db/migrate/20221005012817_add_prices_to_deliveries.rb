class AddPricesToDeliveries < ActiveRecord::Migration[6.1]
  def change
    add_column :deliveries, :price_deliver, :string
    add_column :deliveries, :price, :string
  end
end
