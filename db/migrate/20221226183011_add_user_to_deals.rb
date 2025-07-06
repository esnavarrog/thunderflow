class AddUserToDeals < ActiveRecord::Migration[6.1]
  def change
    add_reference :deals, :user, foreign_key: true
  end
end
