module Concerns
  module Contact
    module Archivable
      extend ActiveSupport::Concern

      class_methods do
        def archivable
          unlinked.find_each.select(&:archivable?)
        end
      end

      def archivable?(post: false)
        inactive = inactive?

        puts "Found archivable contact id(#{id}), code (#{code})" if inactive && !post

        inactive
      end

      def archive(verified: false, notify: true)
        unless verified
          raise 'Contact cannot be archived' unless archivable?(post: true)
        end

        notify_registrar_about_archivation if notify
        destroy!
      end

      private

      def notify_registrar_about_archivation
        registrar.notifications.create!(text: I18n.t('contact_has_been_archived',
                                                contact_code: code,
                                                orphan_months: Setting.orphans_contacts_in_months))
      end

      def inactive?
        if DomainVersion.contact_unlinked_more_than?(contact_id: id, period: inactivity_period)
          return true
        end

        DomainVersion.was_contact_linked?(id) ? false : created_at <= inactivity_period.ago
      end

      def inactivity_period
        Setting.orphans_contacts_in_months.months
      end
    end
  end
end
