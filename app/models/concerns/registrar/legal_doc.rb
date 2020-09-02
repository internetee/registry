module Concerns
  module Registrar
    module LegalDoc
      extend ActiveSupport::Concern

      def legaldoc_mandatory?
        !legaldoc_not_mandatory?
      end

      def legaldoc_not_mandatory?
        setting = Setting.legal_document_is_mandatory
        legaldoc_optout || !setting
      end
    end
  end
end
