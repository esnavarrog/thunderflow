class AddTypeToWithdrawalReceipts < ActiveRecord::Migration[6.1]
  def change
    add_column :withdrawal_receipts, :withdrawal_receipt_type, :integer, default: 0
  end
end
