class CreatePayments < ActiveRecord::Migration[6.1]
  def change
    create_table :payments do |t|
      t.string :description
      t.integer :amount
      t.datetime :pay_date
      t.integer :user_id
      t.integer :payment_method_id
      t.boolean :verified
      t.text :response_json
      t.string :flow_order
      t.string :currency
      t.string :payer
      t.string :media
      t.integer :status
      t.integer :fee
      t.integer :balance
      t.datetime :transfer_date
      t.string :buy_order
      t.string :session_id
      t.string :status_message
      t.timestamps
    end
  end
end
