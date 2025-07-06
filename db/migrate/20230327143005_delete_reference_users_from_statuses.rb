class DeleteReferenceUsersFromStatuses < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :statuses, :users
  end
end
