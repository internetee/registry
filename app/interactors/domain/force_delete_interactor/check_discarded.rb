class Domain
  module ForceDeleteInteractor
    class CheckDiscarded
      include Interactor

      def call
        return unless context.domain.discarded?

        message = 'Force delete procedure cannot be scheduled while a domain is discarded'
        context.fail!(message: message)
      end
    end
  end
end
