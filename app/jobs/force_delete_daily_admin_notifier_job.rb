class ForceDeleteDailyAdminNotifierJob < ApplicationJob
  queue_as :default

  def perform
    domains = Domain.where("'#{DomainStatus::FORCE_DELETE}' = ANY (statuses)")
                    .where("force_delete_start = ?", Time.zone.now)

    return if domains.empty?

    notify_admins(domains)
  end

  private

  def notify_admins(domains)
    summary = generate_summary(domains)
    AdminMailer.force_delete_daily_summary(summary).deliver_now
  end

  def generate_summary(domains)
    domains.map do |domain|
      {
        name: domain.name,
        reason: determine_reason(domain),
        force_delete_type: domain.force_delete_type,
        force_delete_start: domain.force_delete_start,
        force_delete_date: domain.force_delete_date
      }
    end
  end

  def determine_reason(domain)
    if domain.template_name.present?
      domain.template_name
    elsif domain.status_notes[DomainStatus::FORCE_DELETE].present?
      "Manual force delete: #{domain.status_notes[DomainStatus::FORCE_DELETE]}"
    else
      'Unknown reason'
    end
  end
end
