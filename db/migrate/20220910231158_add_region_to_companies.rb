class AddRegionToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :region, :string
  end
end
