class CreateStatuses < ActiveRecord::Migration[6.1]
  def change
    create_table :statuses do |t|
      t.references :delivery, null: false, foreign_key: true
      t.integer :status
      t.references :user, null: false, foreign_key: true
      t.string :image
      t.string :observation

      t.timestamps
    end
  end
end
