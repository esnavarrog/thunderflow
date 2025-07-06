class CreateResources < ActiveRecord::Migration[6.1]
  def change
    create_table :resources do |t|
      t.references :company, null: false, foreign_key: true
      t.string :web_address
      t.boolean :is_valid, default:false
      t.integer :status, default:0

      t.timestamps
    end
  end
end
