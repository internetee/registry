module Domains
  module CancelForceDelete
    class RemoveForceDeleteStatuses < Base
      def execute
        domain.statuses.delete(DomainStatus::FORCE_DELETE)
        domain.statuses.delete(DomainStatus::SERVER_RENEW_PROHIBITED)
        domain.statuses.delete(DomainStatus::SERVER_TRANSFER_PROHIBITED)
        domain.statuses.delete(DomainStatus::CLIENT_HOLD)
        domain.save(validate: false)
      end
    end
  end
end
