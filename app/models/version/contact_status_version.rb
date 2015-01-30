class ContactStatusVersion < PaperTrail::Version
  include VersionSession
  self.table_name    = :log_contact_statuses
  self.sequence_name = :log_contact_statuses_id_seq
end
