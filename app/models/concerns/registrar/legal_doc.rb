module Concerns
  module Registrar
    module LegalDoc
      extend ActiveSupport::Concern

      def legaldoc_mandatory?
        !legaldoc_not_mandatory?
      end

      def legaldoc_not_mandatory?
        legaldoc_optout || !Setting.legal_document_is_mandatory
      end
    end
  end
end
