class DomainVersion < PaperTrail::Version
  include UserEvents

  scope :deleted, -> { where(event: 'destroy') }

  self.table_name = :domain_versions
  self.sequence_name = :domain_version_id_seq

  def load_snapshot
    YAML.load(snapshot)
  end

  def previous?
    return true if previous
    false
  end

  def changed_elements
    return [] unless previous?
    @changes = []
    @previous_snap = previous.load_snapshot
    @snap = load_snapshot
    [:owner_contact, :tech_contacts, :admin_contacts, :nameservers, :domain].each do |key|
      @changes << key unless @snap[key] == @previous_snap[key]
    end

    @changes
  end
end
