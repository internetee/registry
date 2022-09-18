class CheckForceDeleteLiftJob < ApplicationJob
  def perform(validation_event_id, contact_id)
    @event = ValidationEvent.find(validation_event_id)
    @contact = Contact.find(contact_id)

    return unless @contact.need_to_lift_force_delete?

    domain_list.each { |domain| refresh_status_notes(domain) }
  end

  def domain_list
    domain_contacts = Contact.where(email: @event.email).map(&:domain_contacts).flatten
    registrant_ids = Registrant.where(email: @event.email).pluck(:id)

    (domain_contacts.map(&:domain).flatten + Domain.where(registrant_id: registrant_ids)).uniq
  end

  def refresh_status_notes(domain)
    return unless domain.status_notes[DomainStatus::FORCE_DELETE]

    domain.status_notes[DomainStatus::FORCE_DELETE].slice!(@contact.email_history)
    domain.status_notes[DomainStatus::FORCE_DELETE].lstrip!
    domain.save(validate: false)

    notify_registrar(domain) unless domain.status_notes[DomainStatus::FORCE_DELETE].empty?
  end

  def notify_registrar(domain)
    domain.registrar.notifications.create!(text: I18n.t('force_delete_auto_email',
                                                        domain_name: domain.name,
                                                        outzone_date: domain.outzone_date,
                                                        purge_date: domain.purge_date,
                                                        email: domain.status_notes[DomainStatus::FORCE_DELETE]))
  end
end
