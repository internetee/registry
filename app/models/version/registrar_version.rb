class RegistrarVersion < PaperTrail::Version
  self.table_name    = :log_registrars
  self.sequence_name = :log_registrars_id_seq
end
