class AddNameProfileToCompanies < ActiveRecord::Migration[7.2]
  def change
    add_column :companies, :name_profile, :integer, default: 0
  end
end
