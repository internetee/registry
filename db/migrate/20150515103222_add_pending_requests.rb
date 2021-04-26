class AddPendingRequests < ActiveRecord::Migration[6.0]
  def change
    add_column :domains, :pending_json, :json
  end
end
