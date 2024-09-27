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

        puts "Try to save domain: #{domain.name} with statuses: #{statuses}"
        domain.save(validate: false)
      end
    end
  end
end
