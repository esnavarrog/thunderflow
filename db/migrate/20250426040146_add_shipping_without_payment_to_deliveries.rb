class AddShippingWithoutPaymentToDeliveries < ActiveRecord::Migration[7.2]
  def change
    add_column :deliveries, :shipping_without_payment, :integer
  end
end
