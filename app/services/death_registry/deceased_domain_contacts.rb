# frozen_string_literal: true

module DeathRegistry
  # Handles admin and tech contacts with a death date. Death gives grounds for
  # a force delete only against the registrant, so:
  # - a contact the domain can do without (a tech contact, or an admin contact
  #   when the domain still meets the admin contact requirement) is removed;
  # - the last required admin contact (an organisation's or a minor's domain)
  #   puts the domain into a soft force delete until it is replaced.
  #   CheckForceDeleteLift lifts it once the domain has enough living admin
  #   contacts.
  #
  # The person is looked up again first; one who is no longer in the death
  # registry has the death date cleared.
  class DeceasedDomainContacts
    FORCE_DELETE_REASON = 'deceased_admin_contact'

    attr_reader :removed, :force_deletes

    def initialize(lookup:)
      @lookup = lookup
      @removed = 0
      @force_deletes = 0
    end

    def call
      Contact.where.not(death_date: nil)
             .where('EXISTS (SELECT 1 FROM domain_contacts WHERE domain_contacts.contact_id = contacts.id)')
             .find_each do |contact|
        next contact.clear_death_date! unless @lookup.deceased?(contact.ident)

        contact.domain_contacts.includes(domain: :registrar).find_each do |domain_contact|
          handle(domain_contact, contact)
        end
      end

      self
    end

    private

    def handle(domain_contact, contact)
      domain = domain_contact.domain

      if domain_contact.is_a?(TechDomainContact) || admin_contact_removable?(domain)
        remove(domain_contact, contact)
      elsif !domain.force_delete_scheduled?
        schedule_force_delete(domain, contact)
      end
    end

    def admin_contact_removable?(domain)
      domain.admin_domain_contacts.count > domain.required_admin_contacts_count
    end

    # Saving the domain afterwards records the change in the domain history
    # and updates WHOIS.
    def remove(domain_contact, contact)
      domain = domain_contact.domain
      role = domain_contact.is_a?(TechDomainContact) ? 'tech' : 'admin'

      Domain.transaction do
        domain_contact.destroy!
        domain.reload.save!(validate: false)
      end

      domain.registrar.notifications.create!(
        text: I18n.t("death_registry_#{role}_contact_removed", domain_name: domain.name,
                                                               contact_code: contact.code),
        attached_obj_id: domain.id,
        attached_obj_type: domain.class.name
      )
      @removed += 1
    end

    def schedule_force_delete(domain, contact)
      result = domain.schedule_force_delete(type: :soft, notify_by_email: true, reason: FORCE_DELETE_REASON,
                                            notes: "Admin contact #{contact.code} has died")
      return @force_deletes += 1 if result.valid?

      Rails.logger.warn("#{self.class.name}: #{domain.name}: #{result.errors.full_messages.join(', ')}")
    end
  end
end
