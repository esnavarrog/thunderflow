class AddReasonRejectedToDeals < ActiveRecord::Migration[6.1]
  def change
    add_column :deals, :reason_rejected, :string
  end
end
