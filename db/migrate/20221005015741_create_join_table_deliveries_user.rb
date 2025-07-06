class CreateJoinTableDeliveriesUser < ActiveRecord::Migration[6.1]
  def change
    create_join_table :deliveries, :users do |t|
      t.index :delivery_id
      t.index :user_id
    end
  end
end
