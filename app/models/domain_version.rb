class DomainVersion < PaperTrail::Version
  self.table_name = :domain_versions
  self.sequence_name = :domain_version_id_seq
end
