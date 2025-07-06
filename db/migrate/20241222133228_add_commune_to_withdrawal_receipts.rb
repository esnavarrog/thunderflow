class AddCommuneToWithdrawalReceipts < ActiveRecord::Migration[6.1]
  def change
    add_column :withdrawal_receipts, :commune, :string
  end
end
