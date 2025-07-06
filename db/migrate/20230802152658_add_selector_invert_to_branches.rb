class AddSelectorInvertToBranches < ActiveRecord::Migration[6.1]
  def change
    add_column :branches, :invert, :boolean, default:false
  end
end
