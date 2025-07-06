class AddBranchToResources < ActiveRecord::Migration[6.1]
  def change
    add_reference :resources, :branch, null: false, foreign_key: true
  end
end
