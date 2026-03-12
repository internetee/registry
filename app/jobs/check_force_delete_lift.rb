class CheckForceDeleteLift < ApplicationJob
  queue_as :default

  def perform
    domains = find_domains_to_lift_force_delete

    handle_refresh_status(domains) if domains.present?

    domains_to_process = find_domains_to_process(domains)

    domains_to_process.each do |domain|
      Domains::ForceDeleteLift::Base.run(domain: domain)
    end

    sync_force_delete_status_notes
  end

  private

  def find_domains_to_lift_force_delete
    Domain.where("'#{DomainStatus::FORCE_DELETE}' = ANY (statuses)").includes(:registrant, :contacts)
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

  def sync_force_delete_status_notes
    invalid_email_fd_domains = Domain.where("'#{DomainStatus::FORCE_DELETE}' = ANY (statuses)")
                                     .where("force_delete_data->'template_name' = ?", 'invalid_email')
                                     .includes(registrant: :validation_events,
                                               contacts: :validation_events)

    invalid_email_fd_domains.each do |domain|
      update_status_notes_for_domain(domain)
    end
  end

  def update_status_notes_for_domain(domain)
    current_notes = domain.status_notes[DomainStatus::FORCE_DELETE]
    return if current_notes.blank?

    current_invalid_emails = collect_current_invalid_emails(domain)
    new_notes = current_invalid_emails.join(' ')

    return if current_notes == new_notes
    return if new_notes.blank?

    domain.status_notes[DomainStatus::FORCE_DELETE] = new_notes
    domain.save(validate: false)
  end

  def collect_current_invalid_emails(domain)
    failed_emails = domain.contacts.select(&:email_verification_failed?).map(&:email)
    failed_emails << domain.registrant.email if domain.registrant.email_verification_failed?
    failed_emails.uniq
  end
end
