class SettingEntryVersion < PaperTrail::Version
  self.table_name    = :log_setting_entries
  self.sequence_name = :log_setting_entries
end
