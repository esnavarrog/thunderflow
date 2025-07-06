class AddAddressConcatToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :address_concat, :string
    add_column :companies, :latitude, :string
    add_column :companies, :longitude, :string
  end
end
