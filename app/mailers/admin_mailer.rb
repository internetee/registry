class AdminMailer < ApplicationMailer
  def force_delete_daily_summary(force_deleted_summary, lifted_force_delete_summary)
    @force_deleted_domains = force_deleted_summary
    @lifted_domains = lifted_force_delete_summary
    mail(
      to: ENV['admin_notification_email'] || 'admin@registry.test',
      subject: "Force Delete Daily Summary - #{Date.current}"
    )
  end

  def death_registry_problem(problems:)
    @problems = problems
    mail(
      to: ENV['admin_notification_email'] || 'admin@registry.test',
      subject: "Death registry check problem - #{Date.current}"
    )
  end

  def death_registry_dry_run_report(report_path:, checked:, found:)
    @checked = checked
    @found = found
    attachments[File.basename(report_path)] = File.read(report_path)
    mail(
      to: ENV['admin_notification_email'] || 'admin@registry.test',
      subject: "Death registry dry run report - #{Date.current}"
    )
  end
end
