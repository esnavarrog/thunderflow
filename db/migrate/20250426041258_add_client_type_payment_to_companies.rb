class AddClientTypePaymentToCompanies < ActiveRecord::Migration[7.2]
  def change
    add_column :companies, :client_type_payment, :integer
  end
end
