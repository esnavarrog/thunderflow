class AddReferencesUsersToArchives < ActiveRecord::Migration[6.1]
  def change
    add_reference :archives, :user, foreign_key: true
  end
end
