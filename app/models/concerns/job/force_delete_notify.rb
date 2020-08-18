module Concerns
  module Job
    module ForceDeleteNotify
      extend ActiveSupport::Concern

      class_methods do
        def notify_client_hold(domain)
          domain.registrar.notifications.create!(text: I18n.t('force_delete_set_on_domain',
                                                              domain_name: domain.name,
                                                              outzone_date: domain.outzone_date,
                                                              purge_date: domain.purge_date))
        end

        def notify_on_grace_period(domain)
          domain.registrar.notifications.create!(text: I18n.t('grace_period_started_domain',
                                                              domain_name: domain.name,
                                                              date: domain.force_delete_start))
          send_mail(domain)
          domain.update(contact_notification_sent_date: Time.zone.today)
        end

        def send_mail(domain)
          DomainDeleteMailer.forced(domain: domain,
                                    registrar: domain.registrar,
                                    registrant: domain.registrant,
                                    template_name: domain.template_name).deliver_now
        end
      end
    end
  end
end
