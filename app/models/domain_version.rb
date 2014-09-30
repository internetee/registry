class DomainVersion < PaperTrail::Version
  scope :deleted, -> { where(event: 'destroy') }

  self.table_name = :domain_versions
  self.sequence_name = :domain_version_id_seq
end
