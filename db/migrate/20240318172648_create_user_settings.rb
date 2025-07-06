class CreateUserSettings < ActiveRecord::Migration[6.1]
  def change
    create_table :user_settings do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :show_delivery, default: 0

      t.timestamps
    end
  end
end
