class AddUserAsignToDeliveries < ActiveRecord::Migration[6.1]
  def change
    add_column :deliveries, :user_asign_id, :bigint
  end
end
