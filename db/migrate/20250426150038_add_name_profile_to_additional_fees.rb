class AddNameProfileToAdditionalFees < ActiveRecord::Migration[7.2]
  def change
    add_column :additional_fees, :name_profile, :integer, default: 0
  end
end
