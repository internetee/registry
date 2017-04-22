class RenameZonefileSettingsToZones < ActiveRecord::Migration
  def change
    rename_table :zonefile_settings, :zones
  end
end
