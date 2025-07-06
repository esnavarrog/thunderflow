class AddConfirmableUnconfirmedToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :unconfirmed_email, :string # Only if using reconfirmable
  end
end
