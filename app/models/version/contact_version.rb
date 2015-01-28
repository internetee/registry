class ContactVersion < PaperTrail::Version
  include LogTable
  include UserEvents
  # self.table_name = :post_versions
  # self.sequence_name = :post_version_id_seq

  scope :deleted, -> { where(event: 'destroy') }
end
