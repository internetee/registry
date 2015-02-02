class SettingVersion < PaperTrail::Version
  include VersionSession
  self.table_name    = :log_settings
  self.sequence_name = :log_settings_id_seq
end
