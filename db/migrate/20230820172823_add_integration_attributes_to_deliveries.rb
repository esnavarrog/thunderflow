class AddIntegrationAttributesToDeliveries < ActiveRecord::Migration[6.1]
  def change
    add_column :deliveries, :integration_type, :integer
    add_column :deliveries, :integration_order_id, :integer
  end
end
