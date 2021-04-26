class RemoveAddressesWithVersions < ActiveRecord::Migration[6.0]
  def change
    drop_table :addresses
    drop_table :log_addresses
  end
end
