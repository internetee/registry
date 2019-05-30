class ContactVersion < PaperTrail::Version
  include VersionSession
  self.table_name    = :log_contacts
  self.sequence_name = :log_contacts_id_seq

  # scope :deleted, -> { where(event: 'destroy') }
end
