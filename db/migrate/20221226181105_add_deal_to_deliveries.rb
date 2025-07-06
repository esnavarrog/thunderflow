class AddDealToDeliveries < ActiveRecord::Migration[6.1]
  def change
    add_reference :deliveries, :deal, foreign_key: true
  end
end
