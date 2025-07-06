class AddSecretKeyToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :secret_key, :string
  end
end
