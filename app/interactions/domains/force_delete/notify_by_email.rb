module Domains
  module ForceDelete
    class NotifyByEmail < Base
      def execute
        return unless notify_by_email

        domain.skip_whois_record_update = false
        template_name = domain.notification_template(explicit: reason)

        if type == :fast_track
          send_email(template_name)
          domain.update(contact_notification_sent_date: Time.zone.today, template_name: template_name)
        else
          domain.update(template_name: template_name)
        end
      end

      def send_email(template_name)
        DomainDeleteMailer.forced(domain: domain,
                                  registrar: domain.registrar,
                                  registrant: domain.registrant,
                                  template_name: template_name).deliver_now
      end
    end
  end
end
