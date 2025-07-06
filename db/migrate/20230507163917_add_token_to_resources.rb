class AddTokenToResources < ActiveRecord::Migration[6.1]
  def change
    add_column :resources, :token, :string
  end
end
