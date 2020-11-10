class Domain
  module ForceDeleteInteractor
    class PrepareDomain
      include Interactor

      STATUSES_TO_SET = [DomainStatus::FORCE_DELETE,
                         DomainStatus::SERVER_RENEW_PROHIBITED,
                         DomainStatus::SERVER_TRANSFER_PROHIBITED].freeze

      def call
        domain = context.domain
        domain.statuses_before_force_delete = domain.statuses
        domain.statuses |= STATUSES_TO_SET
        domain.save(validate: false)
      end
    end
  end
end
