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
            where('delete_at < ? AND ? != ALL(coalesce(statuses, array[]::varchar[]))',
                  Time.zone.now,
                  DomainStatus::SERVER_DELETE_PROHIBITED)
          else
            where('delete_at < ? AND ? != ALL(coalesce(statuses, array[]::varchar[])) AND' \
                  ' ? != ALL(COALESCE(statuses, array[]::varchar[]))',
                  Time.zone.now,
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
          transaction do
            domain_name.sell_at_auction if domain_name.auctionable?
            destroy!
          end
        else
          discard
        end
      end
    end
  end
end
