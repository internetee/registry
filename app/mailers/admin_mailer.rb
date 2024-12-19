class AdminMailer < ApplicationMailer
  def force_delete_daily_summary(domains_summary)
    @domains = domains_summary
    mail(
      to: ENV['admin_notification_email'] || 'admin@registry.test',
      subject: "Force Delete Daily Summary - #{Date.current}"
    )
  end
end 