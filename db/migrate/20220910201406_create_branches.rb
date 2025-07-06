class CreateBranches < ActiveRecord::Migration[6.1]
  def change
    create_table :branches do |t|
      t.string :name
      t.references :company, null: false, foreign_key: true
      t.integer :status
      t.string :email
      t.string :phone_number
      t.string :street
      t.string :commune
      t.string :address_number
      t.string :responsible_name
      t.string :latitude
      t.string :longitude
      t.string :city
      t.string :country

      t.timestamps
    end
  end
end
