class AddShippingWithoutPaymentToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :shipping_without_payment, :boolean, default: false
  end
end
