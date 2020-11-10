class Domain
  module ForceDeleteInteractor
    class Base
      include Interactor

      private

      def domain
        @domain ||= context.domain
      end
    end
  end
end
