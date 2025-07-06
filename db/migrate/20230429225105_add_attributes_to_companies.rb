class AddAttributesToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :responsible_name, :string
    add_column :companies, :reference, :string
    add_column :companies, :time_open, :time
    add_column :companies, :time_close, :time
  end
end
