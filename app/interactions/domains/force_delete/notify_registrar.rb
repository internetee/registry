module Domains
  module ForceDelete
    class NotifyRegistrar < Base
      def execute
        return notify_deceased_person if reason == 'deceased_person'

        email.present? ? notify_with_email : notify_without_email
      end

      def force_delete_type
        type == :soft ? 'Soft' : 'Fast Track'
      end

      def force_delete_start_date
        if domain.force_delete_start.present?
          domain.force_delete_start&.strftime('%d.%m.%Y')
        else
          (Time.zone.today + Setting.expire_warning_period.days)&.strftime('%d.%m.%Y')
        end
      end

      def notify_deceased_person
        domain.registrar.notifications.create!(
          text: I18n.t('force_delete_deceased_person',
                       domain_name: domain.name,
                       ident: domain.registrant.ident,
                       force_delete_start_date: force_delete_start_date,
                       outzone_date: domain.outzone_date,
                       purge_date: domain.purge_date)
        )
      end

      def notify_without_email
        template = if reason == 'invalid_company'
                     I18n.t('invalid_ident',
                            force_delete_type: force_delete_type,
                            force_delete_start_date: force_delete_start_date,
                            ident: domain.registrant.ident,
                            domain_name: domain.name,
                            outzone_date: domain.outzone_date,
                            purge_date: domain.purge_date,
                            notes: notes)
                   else
                     I18n.t('force_delete_set_on_domain',
                            domain_name: domain.name,
                            outzone_date: domain.outzone_date,
                            purge_date: domain.purge_date)
        end

        return if domain.registrar&.notifications&.last&.text&.include? template

        domain.registrar.notifications.create!(text: template)
      end

      def notify_with_email
        template = if reason == 'invalid_company'
                     I18n.t('invalid_ident',
                            force_delete_type: force_delete_type,
                            force_delete_start_date: force_delete_start_date,
                            ident: domain.registrant.ident,
                            domain_name: domain.name,
                            outzone_date: domain.outzone_date,
                            purge_date: domain.purge_date,
                            notes: notes)
                   else
                     I18n.t('force_delete_auto_email',
                            domain_name: domain.name,
                            outzone_date: domain.outzone_date,
                            purge_date: domain.purge_date,
                            email: email)
        end

        return if domain.registrar&.notifications&.last&.text&.include? template

        domain.registrar.notifications.create!(text: template)
      end
    end
  end
end
