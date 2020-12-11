module Domains
  module CheckBalance
    class SingleDomain < ActiveInteraction::Base
      object :domain,
             class: Epp::Domain

      string :operation
      integer :period
      string :unit

      def execute
        if domain_pricelist.try(:price) # checking if price list is not found
          if current_user.registrar.balance < domain_pricelist.price.amount
            errors.add(:domain, I18n.t('billing_failure_credit_balance_low_for_domain',
                                       domain: domain.name))
            return false
          end
        else
          errors.add(:domain, I18n.t(:active_price_missing_for_operation_with_domain,
                                     domain: domain.name))
          return false
        end
        true
      end

      private

      def domain_pricelist
        domain.pricelist(operation, period.try(:to_i), unit)
      end
    end
  end
end
