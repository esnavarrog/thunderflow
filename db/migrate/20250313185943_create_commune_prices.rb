class CreateCommunePrices < ActiveRecord::Migration[6.1]
  def change
    create_table :commune_prices do |t|
      t.string :commune
      t.decimal :price
      t.string :region_name

      t.timestamps
    end
  end
end
