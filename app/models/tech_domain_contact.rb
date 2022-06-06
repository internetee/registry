class TechDomainContact < DomainContact
  # Audit log is needed, therefore no raw SQL
  def self.replace(current_contact, new_contact)
    affected_domains = []
    skipped_domains = []
    tech_contacts = where(contact: current_contact)

    tech_contacts.includes(:domain).each do |tech_contact|
      if irreplaceable?(tech_contact)
        skipped_domains << tech_contact.domain.name
        next
      end
      begin
        tech_contact.contact = new_contact
        tech_contact.save!
        affected_domains << tech_contact.domain.name
      rescue ActiveRecord::RecordNotUnique
        skipped_domains << tech_contact.domain.name
      end
    end
    [affected_domains.sort, skipped_domains.sort]
  end

  def self.irreplaceable?(tech_contact)
    dn = tech_contact.domain
    dn.bulk_update_prohibited? || dn.update_prohibited? || dn.tech_change_prohibited?
  end
end
