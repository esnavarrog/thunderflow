class AddRegionToBranches < ActiveRecord::Migration[6.1]
  def change
    add_column :branches, :region, :string
  end
end
