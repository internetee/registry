class ReservedDomainVersion < PaperTrail::Version
  include VersionSession
  self.table_name    = :log_reserved_domains
  self.sequence_name = :log_reserved_domains_id_seq
end
