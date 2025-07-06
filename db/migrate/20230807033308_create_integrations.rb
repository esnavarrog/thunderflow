class CreateIntegrations < ActiveRecord::Migration[6.1]
  def change
    create_table :integrations do |t|
      t.string :name
      t.string :url
      t.integer :app_type
      t.string :token
      t.references :company

      t.timestamps
    end
  end
end
