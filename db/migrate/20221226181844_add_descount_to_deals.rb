class AddDescountToDeals < ActiveRecord::Migration[6.1]
  def change
    add_column :deals, :descount, :decimal
  end
end
