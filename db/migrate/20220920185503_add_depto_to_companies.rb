class AddDeptoToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :dpto, :string
  end
end
