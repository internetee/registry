class Domain
  module ForceDelete
    class CheckDiscarded
      include Interactor

      def call
        return unless context.domain.discarded?

        raise StandardError,
              'Force delete procedure cannot be scheduled while a domain is discarded'
      end
    end
  end
end
