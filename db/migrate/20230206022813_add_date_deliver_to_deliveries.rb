class AddDateDeliverToDeliveries < ActiveRecord::Migration[6.1]
  def change
    add_column :deliveries, :date_deliver_at, :datetime
  end
end
