class AddReferencesToDeliveries < ActiveRecord::Migration[6.1]
  def change
    add_reference :deliveries, :branch, null: false, foreign_key: true
  end
end
