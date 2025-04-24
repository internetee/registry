class AdminDomainContact < DomainContact
  include AgeValidation

  validate :validate_contact_age

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def self.replace(current_contact, new_contact)
    affected_domains = []
    skipped_domains = []
    admin_contacts = where(contact: current_contact)

    admin_contacts.includes(:domain).find_each do |admin_contact|
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
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  private

  def validate_contact_age
    return unless contact&.underage?

    errors.add(:base, :contact_too_young)
  end
end
