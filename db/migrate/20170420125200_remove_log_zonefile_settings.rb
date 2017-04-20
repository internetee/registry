class RemoveLogZonefileSettings < ActiveRecord::Migration
  def change
    drop_table :log_zonefile_settings
  end
end
