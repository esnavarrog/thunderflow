class AddParamsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :name, :string
    add_column :users, :last_name, :string
    add_column :users, :avatar, :string
    add_column :users, :rut, :string
    add_column :users, :role, :integer, default:0
    add_column :users, :phone_number, :string
    add_column :users, :status, :integer, default:0
    add_column :users, :term_and_conditions, :boolean, default:0
  end
end
