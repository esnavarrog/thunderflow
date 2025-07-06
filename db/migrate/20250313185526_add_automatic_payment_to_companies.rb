class AddAutomaticPaymentToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :automatic_payment, :boolean, default: true
  end
end
