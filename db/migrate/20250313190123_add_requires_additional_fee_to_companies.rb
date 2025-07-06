class AddRequiresAdditionalFeeToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :requires_additional_fee, :boolean, default: true
  end
end
