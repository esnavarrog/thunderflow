class AddDealAndCompanyToPayments < ActiveRecord::Migration[6.1]
  def change
    add_reference :payments, :deal, foreign_key: true
    add_reference :payments, :company, foreign_key: true
  end
end
