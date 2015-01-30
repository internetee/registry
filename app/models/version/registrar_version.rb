class RegistrarVersion < PaperTrail::Version
  include VersionSession
  self.table_name    = :log_registrars
  self.sequence_name = :log_registrars_id_seq
end
