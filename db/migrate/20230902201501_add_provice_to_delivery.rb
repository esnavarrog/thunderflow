class AddProviceToDelivery < ActiveRecord::Migration[6.1]
  def change
    add_column :deliveries, :provice, :string
  end
end
