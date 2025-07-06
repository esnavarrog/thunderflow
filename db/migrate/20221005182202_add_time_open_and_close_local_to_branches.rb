class AddTimeOpenAndCloseLocalToBranches < ActiveRecord::Migration[6.1]
  def change
    add_column :branches, :time_open, :time
    add_column :branches, :time_close, :time
  end
end
