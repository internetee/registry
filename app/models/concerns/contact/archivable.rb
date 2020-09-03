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

        log("Found archivable contact id(#{id}), code (#{code})") if inactive && !post

        inactive
      end

      def archive(verified: false)
        unless verified
          raise 'Contact cannot be archived' unless archivable?(post: true)
        end

        destroy!
      end

      private

      def inactive?
        if DomainVersion.contact_unlinked_more_than?(contact_id: id, period: inactivity_period)
          return true
        end

        DomainVersion.was_contact_linked?(id) ? false : created_at <= inactivity_period.ago
      end

      def inactivity_period
        Setting.orphans_contacts_in_months.months
      end

      def log(msg)
        @logger ||= Logger.new(STDOUT)
        @logger.info(msg)
      end
    end
  end
end
