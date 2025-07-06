class AddComToDeliveries < ActiveRecord::Migration[6.1]
  def change
    add_reference :deliveries, :company, null: true, foreign_key: true
  end
end
