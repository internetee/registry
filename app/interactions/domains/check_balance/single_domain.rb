module Domains
  module CheckBalance
    class SingleDomain < ActiveInteraction::Base
      object :domain,
             class: Epp::Domain

      string :operation
      integer :period
      string :unit

      def execute
        if domain_pricelist.try(:price)
          price = domain_pricelist.price.amount
          return price if balance_ok?(price)

          domain.add_epp_error(2104, nil, nil, I18n.t(:not_enough_funds))
          errors.add(:domain, I18n.t(:billing_failure_credit_balance_low, domain: domain.name))
        else
          domain.add_epp_error(2104, nil, nil, I18n.t(:active_price_missing_for_this_operation))
          errors.add(:domain, I18n.t(:active_price_missing_for_operation_with_domain, domain: domain.name))
        end

        false
      end

      private

      def balance_ok?(price)
        domain.registrar.cash_account.balance >= price
      end

      def domain_pricelist
        domain.pricelist(operation, period.try(:to_i), unit)
      end
    end
  end
end
