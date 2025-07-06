class ChangeDeliveryIntegrationOrderIdToDecimal < ActiveRecord::Migration[6.1]
  def change
    change_column :deliveries, :integration_order_id, :decimal
  end
end
