class Version::ContactVersion < PaperTrail::Version
  extend ToCsv
  include VersionSession

  self.table_name    = :log_contacts
  self.sequence_name = :log_contacts_id_seq
end
