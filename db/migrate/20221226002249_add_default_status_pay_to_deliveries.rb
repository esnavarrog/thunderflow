class AddDefaultStatusPayToDeliveries < ActiveRecord::Migration[6.1]
  def up
    remove_column :deliveries, :status_pay
  end
end
