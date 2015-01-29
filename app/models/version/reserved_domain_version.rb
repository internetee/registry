class ReservedDomainVersion < PaperTrail::Version
  self.table_name    = :log_reserved_domains
  self.sequence_name = :log_reserved_domains_id_seq
end
