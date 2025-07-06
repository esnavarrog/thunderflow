class AddApiToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :require_api, :boolean, default:false
    add_column :companies, :accepted_api, :boolean, default:false
  end
end
