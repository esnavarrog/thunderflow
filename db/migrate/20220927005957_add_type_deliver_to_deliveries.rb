class AddTypeDeliverToDeliveries < ActiveRecord::Migration[6.1]
  def change
    add_column :deliveries, :type_deliver, :string
    add_column :deliveries, :time_deliver_open, :time
    add_column :deliveries, :time_deliver_close, :time
  end
end
