class AddDeptoToBranch < ActiveRecord::Migration[6.1]
  def change
    add_column :branches, :dpto, :string
  end
end
