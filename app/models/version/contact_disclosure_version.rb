class ContactDisclosureVersion < PaperTrail::Version
  self.table_name    = :log_contact_disclosures
  self.sequence_name = :log_contact_disclosures_id_seq
end
