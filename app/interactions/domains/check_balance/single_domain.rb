module Domains
  module CheckBalance
    class SingleDomain < ActiveInteraction::Base
      object :domain,
             class: Epp::Domain

      string :operation
      integer :period
      string :unit

      def execute
        return domain_pricelist.price.amount if domain_pricelist.try(:price)

        errors.add(:domain, I18n.t(:active_price_missing_for_operation_with_domain,
                                   domain: domain.name))
        false
      end

      private

      def domain_pricelist
        domain.pricelist(operation, period.try(:to_i), unit)
      end
    end
  end
end
