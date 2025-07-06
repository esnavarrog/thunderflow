class AddNameToResources < ActiveRecord::Migration[6.1]
  def change
    add_column :resources, :name, :string
  end
end
