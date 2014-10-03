class ContactVersion < PaperTrail::Version
  include UserEvents

  scope :deleted, -> { where(event: 'destroy') }

  self.table_name = :contact_versions
  self.sequence_name = :contact_version_id_seq

end
