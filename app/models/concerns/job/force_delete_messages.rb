module Concerns
  module Job
    module ForceDeleteMessages
      extend ActiveSupport::Concern

      class_methods do
        def log_prepare_client_hold
          return if Rails.env.test?

          STDOUT << "#{Time.zone.now.utc} - Setting client_hold to domains\n"
        end

        def log_start_client_hold(domain)
          return if Rails.env.test?

          STDOUT << "#{Time.zone.now.utc} DomainCron.start_client_hold: ##{domain.id} "\
                    "(#{domain.name}) #{domain.changes}\n"
        end

        def log_end_end_client_hold(domain)
          return if Rails.env.test?

          STDOUT << "#{Time.zone.now.utc} - Successfully set client_hold on (#{domain.name})"
        end

        def notify_client_hold(domain)
          domain.registrar.notifications.create!(text: I18n.t('client_hold_set_on_domain',
                                                              domain_name: domain.name,
                                                              date: domain.force_delete_start))
        end

        def notify_on_grace_period(domain)
          domain.registrar.notifications.create!(text: I18n.t('grace_period_started_domain',
                                                              domain_name: domain.name,
                                                              date: domain.force_delete_start))
        end
      end
    end
  end
end
