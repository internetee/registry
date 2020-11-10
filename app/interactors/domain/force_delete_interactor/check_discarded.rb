class Domain
  module ForceDeleteInteractor
    class CheckDiscarded < Base
      def call
        return unless domain.discarded?

        message = 'Force delete procedure cannot be scheduled while a domain is discarded'
        context.fail!(message: message)
      end
    end
  end
end
