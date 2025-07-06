class AddAttributesToStatuses < ActiveRecord::Migration[6.1]
  def change
    add_column :statuses, :description, :string
    add_column :statuses, :receiver_name, :string
    add_column :statuses, :receiver_rut, :string
    add_column :statuses, :receiver_phone, :string
  end
end
