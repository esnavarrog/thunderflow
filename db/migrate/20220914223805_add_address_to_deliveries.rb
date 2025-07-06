class AddAddressToDeliveries < ActiveRecord::Migration[6.1]
  def change
    add_column :deliveries, :address_street, :string
    add_column :deliveries, :address_number, :string
    add_column :deliveries, :region, :string
    add_column :deliveries, :commune, :string
    add_column :deliveries, :reference, :string
    add_column :deliveries, :city, :string
    add_column :deliveries, :phone_number, :string
    add_column :deliveries, :contact_name, :string
    add_column :deliveries, :contact_lastname, :string
    add_column :deliveries, :email, :string
  end
end
