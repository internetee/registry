module Domains
  module BulkRenew
    class SingleDomainRenew < ActiveInteraction::Base
      object :domain,
             class: Epp::Domain

      def execute

      end
    end
  end
end
