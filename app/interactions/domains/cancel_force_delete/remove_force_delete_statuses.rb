module Domains
  module CancelForceDelete
    class RemoveForceDeleteStatuses < Base
      def execute
        domain_statuses = [DomainStatus::FORCE_DELETE,
                           DomainStatus::SERVER_RENEW_PROHIBITED,
                           DomainStatus::SERVER_TRANSFER_PROHIBITED,
                           DomainStatus::CLIENT_HOLD]
        rejected_statuses = domain.statuses.reject { |a| domain_statuses.include? a }
        domain.statuses = rejected_statuses
        domain.save(validate: false)
      end
    end
  end
end
