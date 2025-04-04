class AdminMailer < ApplicationMailer
  def force_delete_daily_summary(force_deleted_summary, lifted_force_delete_summary)
    @force_deleted_domains = force_deleted_summary
    @lifted_domains = lifted_force_delete_summary
    mail(
      to: ENV['admin_notification_email'] || 'admin@registry.test',
      subject: "Force Delete Daily Summary - #{Date.current}"
    )
  end
end
