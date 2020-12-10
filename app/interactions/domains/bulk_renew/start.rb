module Domains
  module BulkRenew
    class Start < ActiveInteraction::Base
      array :domains do
        object class: Epp::Domain
      end

      def execute

      end
    end
  end
end
