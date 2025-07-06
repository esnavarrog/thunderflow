class CreateWithdrawalReceipts < ActiveRecord::Migration[6.1]
  def change
    create_table :withdrawal_receipts do |t|
      t.references :user, foreign_key: true
      t.references :company, foreign_key: true
      t.integer :sender_local_plain
      t.integer :sender_local_check
      t.integer :returned_amount
      t.string :name_client
      t.datetime :issued_at

      t.timestamps
    end
  end
end
