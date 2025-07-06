class AddAddressConcatToDeliveries < ActiveRecord::Migration[6.1]
  def change
    add_column :deliveries, :address_concat, :string
    add_column :deliveries, :complete_name, :string
    add_column :branches, :address_concat, :string
    add_column :deliveries, :description, :string
  end
end
