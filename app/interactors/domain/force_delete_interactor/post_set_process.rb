class Domain
  module ForceDeleteInteractor
    class PostSetProcess < Base
      def call
        statuses = domain.statuses
        # Stop all pending actions
        statuses.delete(DomainStatus::PENDING_UPDATE)
        statuses.delete(DomainStatus::PENDING_TRANSFER)
        statuses.delete(DomainStatus::PENDING_RENEW)
        statuses.delete(DomainStatus::PENDING_CREATE)

        # Allow deletion
        statuses.delete(DomainStatus::CLIENT_DELETE_PROHIBITED)
        statuses.delete(DomainStatus::SERVER_DELETE_PROHIBITED)
        domain.save(validate: false)
      end
    end
  end
end
