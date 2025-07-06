class DeleteIndexUsersFromStatuses < ActiveRecord::Migration[6.1]
  def change
    remove_index :statuses, name: "index_statuses_on_user_id"
  end
end
