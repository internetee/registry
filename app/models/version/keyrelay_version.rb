class KeyrelayVersion < PaperTrail::Version
  include VersionSession
  self.table_name    = :log_keyrelays
  self.sequence_name = :log_keyrelays_id_seq
end
