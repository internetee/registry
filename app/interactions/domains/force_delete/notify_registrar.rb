module Domains
  module ForceDelete
    class NotifyRegistrar < Base
      def execute
        return notify_deceased_person if reason == 'deceased_person'
        return notify_deceased_admin_contact if reason == 'deceased_admin_contact'

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
                       death_date: domain.registrant.death_date&.strftime('%d.%m.%Y'),
                       force_delete_start_date: force_delete_start_date,
                       outzone_date: domain.outzone_date&.strftime('%d.%m.%Y'),
                       purge_date: domain.purge_date&.strftime('%d.%m.%Y'))
        )
      end

      def notify_deceased_admin_contact
        domain.registrar.notifications.create!(
          text: I18n.t('force_delete_deceased_admin_contact',
                       domain_name: domain.name,
                       ident: deceased_admin_contact_idents,
                       force_delete_start_date: domain.force_delete_start&.strftime('%d.%m.%Y') || '-',
                       outzone_date: domain.outzone_date&.strftime('%d.%m.%Y'),
                       purge_date: domain.purge_date&.strftime('%d.%m.%Y'))
        )
      end

      # The deceased admin contact is still on the domain when the force delete starts.
      def deceased_admin_contact_idents
        domain.admin_contacts.reject { |contact| contact.death_date.nil? }.map(&:ident).join(', ')
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
