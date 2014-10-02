class ContactVersion < PaperTrail::Version
  scope :deleted, -> { where(event: 'destroy') }

  self.table_name = :contact_versions
  self.sequence_name = :contact_version_id_seq

  class << self

    def registrar_events(id)
      registrar = Registrar.find(id)
      @events = []
      registrar.users.each { |user| @events << user_contacts(user.id) }
      registrar.epp_users.each { |user| @events << user_contacts(user.id) }
      @events
    end

    def user_events(id, epp_user_id=nil)
      contacts = []
      contacts << user_contacts(id)
      contacts << epp_user_contacts(epp_user_id) if epp_user_id
      contacts
    end

    def user_contacts(id)
      where(whodunnit: id.to_s)
    end

    def epp_user_contacts(id)
      where(whodunnit: "#{id}-EppUser")
    end
  end
end
