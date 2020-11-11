module ForceDeleteInteraction
  class NotifyByEmail < Base
    def execute
      return unless notify_by_email

      if type == :fast_track
        send_email
        domain.update(contact_notification_sent_date: Time.zone.today)
      else
        domain.update(template_name: domain.notification_template)
      end
    end

    def send_email
      DomainDeleteMailer.forced(domain: domain,
                                registrar: domain.registrar,
                                registrant: domain.registrant,
                                template_name: domain.notification_template).deliver_now
    end
  end
end
