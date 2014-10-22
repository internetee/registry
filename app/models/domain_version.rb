class DomainVersion < PaperTrail::Version
  include UserEvents

  scope :deleted, -> { where(event: 'destroy') }

  self.table_name = :domain_versions
  self.sequence_name = :domain_version_id_seq

  def load_snapshot
    YAML.load(snapshot)
  end
end
