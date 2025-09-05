module Domains
  module ForceDelete
    class PrepareDomain < Base
      STATUSES_TO_SET = [DomainStatus::FORCE_DELETE,
                         DomainStatus::SERVER_RENEW_PROHIBITED,
                         DomainStatus::SERVER_TRANSFER_PROHIBITED].freeze

      def execute
        domain.force_delete_domain_statuses_history = domain.statuses
        domain.statuses |= STATUSES_TO_SET
        domain.skip_whois_record_update = true
      end
    end
  end
end
