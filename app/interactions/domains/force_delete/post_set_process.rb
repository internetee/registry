module Domains
  module ForceDelete
    class PostSetProcess < Base
      def execute
        statuses = domain.statuses
        # Stop all pending actions
        statuses.delete(DomainStatus::PENDING_UPDATE)
        statuses.delete(DomainStatus::PENDING_TRANSFER)
        statuses.delete(DomainStatus::PENDING_RENEW)
        statuses.delete(DomainStatus::PENDING_CREATE)

        # Allow deletion
        statuses.delete(DomainStatus::CLIENT_DELETE_PROHIBITED)
        domain.skip_whois_record_update = notify_by_email ? true : false
      end
    end
  end
end
