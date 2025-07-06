class CreateUserAccesses < ActiveRecord::Migration[6.1]
  def change
    create_table :user_accesses do |t|
      t.integer :access_type
      t.string :invitation_email
      t.references :company, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.boolean :is_valid

      t.timestamps
    end
  end
end
