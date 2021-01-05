module Concerns
  module Domain
    module Releasable
      extend ActiveSupport::Concern

      class_methods do
        def release_domains
          releasable_domains.each do |domain|
            domain.release
            yield domain if block_given?
          end
        end

        private

        def releasable_domains
          if release_to_auction
            where('(delete_date <= ? OR force_delete_date <= ?)' \
              ' AND ? != ALL(coalesce(statuses, array[]::varchar[]))',
                  Time.zone.today,
                  Time.zone.today,
                  DomainStatus::SERVER_DELETE_PROHIBITED)
          else
            where('(delete_date <= ? OR force_delete_date <= ?)' \
              ' AND ? != ALL(coalesce(statuses, array[]::varchar[])) AND' \
                  ' ? != ALL(COALESCE(statuses, array[]::varchar[]))',
                  Time.zone.today,
                  Time.zone.today,
                  DomainStatus::SERVER_DELETE_PROHIBITED,
                  DomainStatus::DELETE_CANDIDATE)
          end
        end
      end

      included do
        class_attribute :release_to_auction
        self.release_to_auction = ENV['release_domains_to_auction'] == 'true'
      end

      def release
        if release_to_auction
          lock!
          to_stdout 'Destroying domain'
          destroy!
          to_stdout "Checking if domain_name is auctionable: #{domain_name.auctionable?}"
          domain_name.sell_at_auction if domain_name.auctionable?

          to_stdout 'Sending registrar notification'
          registrar.notifications.create!(text: "#{I18n.t(:domain_deleted)}: #{name}",
                                          attached_obj_id: id,
                                          attached_obj_type: self.class)
        else
          discard
        end
      end

      def to_stdout(message)
        time = Time.zone.now.utc
        STDOUT << "#{time} - #{message}\n" unless Rails.env.test?
      end
    end
  end
end
