class NameserverVersion < PaperTrail::Version
  self.table_name    = :log_nameservers
  self.sequence_name = :log_nameservers_id_seq
end
