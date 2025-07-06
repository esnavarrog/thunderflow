class AddDefaultPriceToBranches < ActiveRecord::Migration[6.1]
  def change
    add_column :branches, :default_price, :integer
  end
end
