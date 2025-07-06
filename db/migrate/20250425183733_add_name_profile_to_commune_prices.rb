class AddNameProfileToCommunePrices < ActiveRecord::Migration[7.2]
  def change
    add_column :commune_prices, :name_profile, :integer, default: 0
  end
end
