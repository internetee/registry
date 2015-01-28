class DomainVersion < PaperTrail::Version
  include LogTable
  include UserEvents
  # TODO: remove old
  # include DomainVersionObserver if Setting.whois_enabled  # unless Setting.whois_enabled

  scope :deleted, -> { where(event: 'destroy') }

  # TODO: remove old
  # def load_snapshot
    # snapshot ? YAML.load(snapshot) : {}
  # end

  # TODO: remove old
  # def previous?
    # return true if previous
    # false
  # end

  # TODO: remove old
  # def name
    # name = reify.try(:name)
    # name = load_snapshot[:domain].try(:[], :name) unless name
    # name
  # end

  # TODO: remove old
  # def changed_elements
    # return [] unless previous?
    # @changes = []
    # @previous_snap = previous.load_snapshot
    # @snap = load_snapshot
    # [:owner_contact, :tech_contacts, :admin_contacts, :nameservers, :domain].each do |key|
      # @changes << key unless @snap[key] == @previous_snap[key]
    # end

    # @changes
  # end
end
