class ForceDeleteDailyAdminNotifierJob < ApplicationJob
  queue_as :default

  def perform()
    notify_about_force_deleted_domains(force_deleted_domains, lifted_force_delete_domains)
  end

  private

  def force_deleted_domains
    Domain.where("json_statuses_history->>'force_delete_domain_statuses_history_data' IS NOT NULL").
          where("(json_statuses_history->'force_delete_domain_statuses_history_data'->>'date')::timestamp >= ? AND (json_statuses_history->'force_delete_domain_statuses_history_data'->>'date')::timestamp <= ?",
                Time.zone.yesterday.beginning_of_day,
                Time.zone.yesterday.end_of_day)
  end

  def lifted_force_delete_domains
    Domain.where("json_statuses_history->>'lift_force_delete_domain_statuses_history_data' IS NOT NULL")
          .where("(json_statuses_history->'lift_force_delete_domain_statuses_history_data'->>'date')::timestamp >= ? AND (json_statuses_history->'lift_force_delete_domain_statuses_history_data'->>'date')::timestamp <= ?",
                Time.zone.yesterday.beginning_of_day,
                Time.zone.yesterday.end_of_day)
  end

  def notify_about_force_deleted_domains(force_deleted_domains, lifted_force_delete_domains)
    force_deleted_summary = generate_summary_for_force_deleted_domains(force_deleted_domains)
    lifted_force_delete_summary = generate_summary_for_lifted_force_delete_domains(lifted_force_delete_domains)

    AdminMailer.force_delete_daily_summary(force_deleted_summary, lifted_force_delete_summary).deliver_now
  end

  def generate_summary_for_force_deleted_domains(domains)
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

  def generate_summary_for_lifted_force_delete_domains(domains)
    domains.map do |domain|
      {
        name: domain.name,
        reason: domain.json_statuses_history.dig('lift_force_delete_domain_statuses_history_data', 'reason') || 'No reason provided',
        date: domain.json_statuses_history.dig('lift_force_delete_domain_statuses_history_data', 'date')
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
