class ValidationEventCheckForceDeleteJob < ApplicationJob
  def perform(contact_id)
    contact = Contact.find(contact_id)
    email = contact.email

    if contact.need_to_start_force_delete?
      Domains::ForceDeleteEmail::Base.run(email: email)
    elsif contact.need_to_lift_force_delete?
      refresh_status_notes(domain_list(email))
    end
  end

  private

  def refresh_status_notes(domain_list)
    domain_list.each do |domain|
      force_delete_emails = domain.status_notes[DomainStatus::FORCE_DELETE]
      next unless force_delete_emails

      force_delete_emails.slice!(object.email_history)
      force_delete_emails.lstrip!
      domain.save(validate: false)

      notify_registrar(domain) unless domain.status_notes[DomainStatus::FORCE_DELETE].empty?
    end
  end

  def domain_list(email)
    domain_contacts = Contact.where(email: email).map(&:domain_contacts).flatten
    registrant_ids = Registrant.where(email: email).pluck(:id)

    (domain_contacts.map(&:domain).flatten + Domain.where(registrant_id: registrant_ids)).uniq
  end

  def notify_registrar(domain)
    domain.registrar.notifications.create!(text: I18n.t('force_delete_auto_email',
                                                        domain_name: domain.name,
                                                        outzone_date: domain.outzone_date,
                                                        purge_date: domain.purge_date,
                                                        email: domain.status_notes[DomainStatus::FORCE_DELETE]))
  end
end
