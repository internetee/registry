class BlockedDomainVersion < PaperTrail::Version
  self.table_name    = :log_blocked_domains
  self.sequence_name = :log_blocked_domains_id_seq
end
