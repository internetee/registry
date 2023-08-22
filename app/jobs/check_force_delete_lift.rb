class CheckForceDeleteLift < ApplicationJob
  queue_as :default

  def perform
    domains = find_domains_to_lift_force_delete

    handle_refresh_status(domains) if domains.present?

    domains_to_process = find_domains_to_process(domains)

    domains_to_process.each do |domain|
      Domains::ForceDeleteLift::Base.run(domain: domain)
    end
  end

  private

  def find_domains_to_lift_force_delete
    Domain.where("'#{DomainStatus::FORCE_DELETE}' = ANY (statuses)")
          .select { |d| d.registrant.need_to_lift_force_delete? && d.contacts.all?(&:need_to_lift_force_delete?) }
  end

  def find_domains_to_process(domains)
    force_delete_template_domains = Domain.where("force_delete_data->'template_name' = ?", 'invalid_email')
                                          .where("force_delete_data->'force_delete_type' = ?", 'soft')

    (domains + force_delete_template_domains).uniq
  end

  def handle_refresh_status(domains)
    domains.each do |domain|
      registrant = domain.registrant
      event = registrant.validation_events.last
      next if event.blank?

      refresh_status_notes(domain, registrant)
    end
  end

  def refresh_status_notes(domain, registrant)
    return unless domain.status_notes[DomainStatus::FORCE_DELETE]

    domain.status_notes[DomainStatus::FORCE_DELETE].slice!(registrant.email_history || '')
    domain.status_notes[DomainStatus::FORCE_DELETE].lstrip!

    domain.save(validate: false) if domain.changed?
  end
end
