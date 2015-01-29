class DomainContactVersion < PaperTrail::Version
  self.table_name    = :log_domain_contacts
  self.sequence_name = :log_domain_contacts_id_seq
end
