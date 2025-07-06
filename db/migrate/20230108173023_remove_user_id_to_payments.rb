class RemoveUserIdToPayments < ActiveRecord::Migration[6.1]
  def change
    remove_column :payments, :user_id
  end
end
