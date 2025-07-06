class AddIvaToDeals < ActiveRecord::Migration[6.1]
  def change
    add_column :deals, :iva, :integer
    add_column :deals, :price_with_iva, :integer
  end
end
