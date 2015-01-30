class DomainStatusVersion < PaperTrail::Version
  include VersionSession
  self.table_name    = :log_domain_statuses
  self.sequence_name = :log_domain_statuses_id_seq
end
