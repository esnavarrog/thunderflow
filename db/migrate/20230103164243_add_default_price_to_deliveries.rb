class AddDefaultPriceToDeliveries < ActiveRecord::Migration[6.1]
  def change
    add_column :deliveries, :default_price, :integer
  end
end
