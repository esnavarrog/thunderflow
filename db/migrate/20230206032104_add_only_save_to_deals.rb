class AddOnlySaveToDeals < ActiveRecord::Migration[6.1]
  def change
    add_column :deals, :only_save, :boolean, default: false
  end
end
