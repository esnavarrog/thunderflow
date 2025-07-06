class AddAttributesToDeals < ActiveRecord::Migration[6.1]
  def change
    add_reference :deals, :company, null: false, foreign_key: true
    add_column :deals, :total_amount, :integer, default:0
    add_column :deals, :status_deal, :integer, default:0
  end
end
