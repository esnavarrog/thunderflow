class AddTimeOpenAndCloseLocalToDeliveries < ActiveRecord::Migration[6.1]
  def change
    add_column :deliveries, :time_open, :time
    add_column :deliveries, :time_close, :time
  end
end
