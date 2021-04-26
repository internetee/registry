class RemoveLogZonefileSettings < ActiveRecord::Migration[6.0]
  def change
    drop_table :log_zonefile_settings
  end
end
