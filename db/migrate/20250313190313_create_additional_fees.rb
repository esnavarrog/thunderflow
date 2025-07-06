class CreateAdditionalFees < ActiveRecord::Migration[6.1]
  def change
    create_table :additional_fees do |t|
      t.decimal :additional_fee
      t.integer :additional_type
      t.integer :additional_model
      t.string :condition

      t.timestamps
    end
  end
end
