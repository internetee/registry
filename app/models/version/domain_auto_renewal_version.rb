class Version::DomainAutoRenewalVersion < PaperTrail::Version
  include VersionSession
  self.table_name    = :log_domain_auto_renewals
  self.sequence_name = :log_domain_auto_renewals_id_seq
end
