class AddDeptoToDeliveries < ActiveRecord::Migration[6.1]
  def change
    add_column :deliveries, :dpto, :string
  end
end
