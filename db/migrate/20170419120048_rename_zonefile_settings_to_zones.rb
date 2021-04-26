class RenameZonefileSettingsToZones < ActiveRecord::Migration[6.0]
  def change
    rename_table :zonefile_settings, :zones
  end
end
