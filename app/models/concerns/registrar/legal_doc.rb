module Concerns
  module Registrar
    module LegalDoc
      extend ActiveSupport::Concern

      def legaldoc_mandatory?
        !legaldoc_not_mandatory?
      end

      def legaldoc_not_mandatory?
        setting = Setting.find_by(var: 'legal_document_is_mandatory')&.value
        legaldoc_optout || !setting
      end
    end
  end
end
