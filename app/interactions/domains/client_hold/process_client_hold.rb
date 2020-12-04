module Domains
  module ClientHold
    class ProcessClientHold < Base
      object :domain,
             class: Domain,
             description: 'Domain to set ClientHold on'

      # rubocop:disable Metrics/AbcSize
      def execute
        notify_on_grace_period if should_notify_on_soft_force_delete?

        return unless client_holdable?

        domain.statuses << DomainStatus::CLIENT_HOLD
        to_stdout("DomainCron.start_client_hold: #{domain.id} (#{domain.name}) #{domain.changes}\n")

        domain.save(validate: false)
        notify_client_hold

        to_stdout("Successfully set client_hold on (#{domain.name})")
      end

      def notify_on_grace_period
        domain.registrar.notifications.create!(text: I18n.t('grace_period_started_domain',
                                                            domain_name: domain.name,
                                                            date: domain.force_delete_start))
        send_mail if domain.template_name.present?
        domain.update(contact_notification_sent_date: Time.zone.today)
      end

      def notify_client_hold
        domain.registrar.notifications.create!(text: I18n.t('force_delete_set_on_domain',
                                                            domain_name: domain.name,
                                                            outzone_date: domain.outzone_date,
                                                            purge_date: domain.purge_date))
      end

      def send_mail
        DomainDeleteMailer.forced(domain: domain,
                                  registrar: domain.registrar,
                                  registrant: domain.registrant,
                                  template_name: domain.template_name).deliver_now
      end

      def should_notify_on_soft_force_delete?
        domain.force_delete_scheduled? && domain.contact_notification_sent_date.blank? &&
          domain.force_delete_start.to_date <= Time.zone.now.to_date &&
          domain.force_delete_type.to_sym == :soft &&
          !domain.statuses.include?(DomainStatus::CLIENT_HOLD)
      end
      # rubocop:enable Metrics/AbcSize

      def client_holdable?
        domain.force_delete_scheduled? &&
          !domain.statuses.include?(DomainStatus::CLIENT_HOLD) &&
          domain.force_delete_start.present? &&
          force_delete_lte_today && force_delete_lte_valid_date
      end

      def force_delete_lte_today
        domain.force_delete_start + Setting.expire_warning_period.days <= Time.zone.now
      end

      def force_delete_lte_valid_date
        domain.force_delete_start + Setting.expire_warning_period.days <= domain.valid_to
      end
    end
  end
end
