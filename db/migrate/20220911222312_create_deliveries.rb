class CreateDeliveries < ActiveRecord::Migration[6.1]
  def change
    create_table :deliveries do |t|
      t.string :weight
      t.string :height
      t.string :width
      t.string :depth
      t.datetime :date_start
      t.datetime :date_end
      t.integer :status, default:0

      t.timestamps
    end
  end
end
