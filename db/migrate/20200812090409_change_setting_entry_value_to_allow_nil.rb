class ChangeSettingEntryValueToAllowNil < ActiveRecord::Migration[6.0]
  def change
    change_column :setting_entries, :value, :string, null: true
  end
end
