class AddRutToDeliveries < ActiveRecord::Migration[6.1]
  def change
    add_column :deliveries, :rut, :string
  end
end
