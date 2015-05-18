class AddPendingRequests < ActiveRecord::Migration
  def change
    add_column :domains, :pending_json, :json
  end
end
