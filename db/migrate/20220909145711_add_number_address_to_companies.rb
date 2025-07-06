class AddNumberAddressToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :number_address, :string
    add_column :companies, :postal_code, :string
  end
end
