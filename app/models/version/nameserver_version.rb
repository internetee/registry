class NameserverVersion < PaperTrail::Version
  include VersionSession
  self.table_name    = :log_nameservers
  self.sequence_name = :log_nameservers_id_seq
end
