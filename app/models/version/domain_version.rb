class DomainVersion < PaperTrail::Version
  include VersionSession

  self.table_name    = :log_domains
  self.sequence_name = :log_domains_id_seq

  include UserEvents

  scope :deleted, -> { where(event: 'destroy') }
end
