class CreateCompanies < ActiveRecord::Migration[6.1]
  def change
    create_table :companies do |t|
      t.string :rut
      t.string :name
      t.string :address_number
      t.string :street
      t.string :commune
      t.string :email
      t.string :phone_number
      t.string :web_address
      t.integer :status
      t.string :fantasy_name
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
