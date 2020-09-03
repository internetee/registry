module Concerns
  module Contact
    module Archivable
      extend ActiveSupport::Concern

      included do
        class_attribute :inactivity_period, instance_predicate: false, instance_writer: false
        self.inactivity_period = Setting.orphans_contacts_in_months.months
      end

      class_methods do
        def archivable
          unlinked.find_each.select(&:archivable?)
        end
      end

      def archivable?
        inactive?
      end

      def archive
        raise 'Contact cannot be archived' unless archivable?

        destroy!
      end

      private

      def inactive?
        return (created_at <= inactivity_period.ago) unless DomainVersion.was_contact_linked?(id)

        DomainVersion.contact_unlinked_more_than?(contact_id: id, period: inactivity_period)
      end
    end
  end
end
