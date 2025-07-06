class AddStatusPayToDeliveries < ActiveRecord::Migration[6.1]
  def change
    add_column :deliveries, :status_pay, :integer
  end
end
