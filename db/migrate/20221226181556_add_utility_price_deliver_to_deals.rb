class AddUtilityPriceDeliverToDeals < ActiveRecord::Migration[6.1]
  def change
    add_column :deals, :utility, :integer
    add_column :deals, :total_cost, :integer
  end
end
