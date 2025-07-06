class CreateDefaultProfilePrices < ActiveRecord::Migration[7.2]
  def change
    create_table :default_profile_prices do |t|
      t.integer :price, null: false
      t.integer :name_profile, null: false

      t.timestamps
    end
    add_index :default_profile_prices, :name_profile, unique: true
  end
end
