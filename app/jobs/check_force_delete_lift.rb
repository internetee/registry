class CheckForceDeleteLift < ApplicationJob
  queue_as :default

  def perform
    domains = Domain.where("(status_notes->'serverForceDelete') is not null")
                    .select { |d| d.registrant.need_to_lift_force_delete? }

    handle_refresh_status(domains) if domains.present?
    domains = (domains + Domain.where("force_delete_data->'template_name' = ?", 'invalid_email')
                               .where("force_delete_data->'force_delete_type' = ?", 'soft')).uniq

    domains.each do |domain|
      Domains::ForceDeleteLift::Base.run(domain: domain)
    end
  end

  private

  def handle_refresh_status(domains)
    domains.each do |domain|
      registrant = domain.registrant
      event = registrant.validation_events.last
      next if event.blank?

      domain_list(event).each { |d| refresh_status_notes(d, registrant) }
    end
  end

  def domain_list(event)
    domain_contacts = Contact.where(email: event.email).map(&:domain_contacts).flatten
    registrant_ids = Registrant.where(email: event.email).pluck(:id)

    (domain_contacts.map(&:domain).flatten + Domain.where(registrant_id: registrant_ids)).uniq
  end

  def refresh_status_notes(domain, registrant)
    return unless domain.status_notes[DomainStatus::FORCE_DELETE]

    domain.status_notes[DomainStatus::FORCE_DELETE].slice!(registrant.email_history)
    domain.status_notes[DomainStatus::FORCE_DELETE].lstrip!
    domain.save(validate: false)
  end
end
