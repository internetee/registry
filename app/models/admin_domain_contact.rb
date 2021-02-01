class AdminDomainContact < DomainContact
  def self.replace(current_contact, new_contact)
    affected_domains = []
    skipped_domains = []
    admin_contacts = where(contact: current_contact)

    admin_contacts.each do |admin_contact|
      if admin_contact.domain.bulk_update_prohibited?
        skipped_domains << admin_contact.domain.name
        next
      end
      begin
        admin_contact.contact = new_contact
        admin_contact.save!
        affected_domains << admin_contact.domain.name
      rescue ActiveRecord::RecordNotUnique
        skipped_domains << admin_contact.domain.name
      end
    end
    [affected_domains.sort, skipped_domains.sort]
  end
end
