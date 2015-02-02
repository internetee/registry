class ContactDisclosureVersion < PaperTrail::Version
  include VersionSession
  self.table_name    = :log_contact_disclosures
  self.sequence_name = :log_contact_disclosures_id_seq
end
