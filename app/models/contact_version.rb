class ContactVersion < PaperTrail::Version
  self.table_name = :contact_versions
  self.sequence_name = :contact_version_id_seq
end
