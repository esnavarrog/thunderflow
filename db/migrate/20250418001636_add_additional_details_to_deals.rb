class AddAdditionalDetailsToDeals < ActiveRecord::Migration[6.1]
  def change
    add_column :deals, :additional_details, :jsonb, default: {}
  end
end
