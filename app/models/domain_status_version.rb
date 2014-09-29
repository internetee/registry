class DomainStatusVersion < PaperTrail::Version
  self.table_name = :domain_status_versions
  self.sequence_name = :domain_status_version_id_seq
end
