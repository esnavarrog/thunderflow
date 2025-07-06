class AddReferencesToBranches < ActiveRecord::Migration[6.1]
  def change
    add_column :branches, :reference, :string
  end
end
