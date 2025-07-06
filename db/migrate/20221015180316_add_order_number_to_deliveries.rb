class AddOrderNumberToDeliveries < ActiveRecord::Migration[6.1]
  def change
    add_column :deliveries, :order_number, :string
  end
end
