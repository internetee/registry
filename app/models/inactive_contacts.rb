class InactiveContacts
  attr_reader :contacts

  def initialize(contacts = Contact.archivable)
    @contacts = contacts
  end

  def archive
    contacts.each do |contact|
      contact.archive
      yield contact if block_given?
    end
  end
end
