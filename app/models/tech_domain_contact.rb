class TechDomainContact < DomainContact
  # Audit log is needed, therefore no raw SQL
  def self.replace(predecessor, successor)
    affected_domains = []
    skipped_domains = []
    tech_contacts = where(contact: predecessor)

    transaction do
      tech_contacts.each do |tech_contact|
        if tech_contact.domain.discarded?
          skipped_domains << tech_contact.domain.name
          next
        end

        tech_contact.contact = successor
        tech_contact.save!
        affected_domains << tech_contact.domain.name
      end
    end

    return affected_domains.sort, skipped_domains.sort
  end
end
