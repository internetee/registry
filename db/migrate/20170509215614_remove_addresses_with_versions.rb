class RemoveAddressesWithVersions < ActiveRecord::Migration
  def change
    drop_table :addresses
    drop_table :log_addresses
  end
end
