module Concerns
  module Registrar
    module LegalDoc
      extend ActiveSupport::Concern

      def legaldoc_mandatory?
        !legaldoc_optout
      end
    end
  end
end
