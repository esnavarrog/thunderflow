class AddAdditionalAmountToDeals < ActiveRecord::Migration[6.1]
  def change
    add_column :deals, :additional_amount, :decimal, default: 0
  end
end
