class ValidationEventCheckForceDeleteJob < ApplicationJob
  def perform(contact_id)
    @contact = Contact.find(contact_id)
    @email = @contact.email

    if @contact.need_to_start_force_delete?
      Domains::ForceDeleteEmail::Base.run(email: @email)
    elsif @contact.need_to_lift_force_delete?
      refresh_status_notes
    end
  end

  private

  def refresh_status_notes
    domain_list.each do |domain|
      next unless domain.status_notes[DomainStatus::FORCE_DELETE]

      domain.status_notes[DomainStatus::FORCE_DELETE].slice!(@contact.email_history)
      domain.status_notes[DomainStatus::FORCE_DELETE].lstrip!
      domain.save(validate: false)

      notify_registrar(domain) unless domain.status_notes[DomainStatus::FORCE_DELETE].empty?
    end
  end

  def domain_list
    domain_contacts = Contact.where(email: @email).map(&:domain_contacts).flatten
    registrant_ids = Registrant.where(email: @email).pluck(:id)

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
