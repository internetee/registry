class Domain
  module ForceDelete
    class PrepareDomain
      include Interactor

      def call
        domain = context.domain
        domain.statuses_before_force_delete = domain.statuses
        domain.statuses |= domain.class.STATUSES_TO_SET
        domain.save(validate: false)
      end
    end
  end
end
