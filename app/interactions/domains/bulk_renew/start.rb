module Domains
  module BulkRenew
    class Start < ActiveInteraction::Base
      array :domains do
        object class: Epp::Domain
      end
      string :period_element
      object :registrar

      def execute
        if mass_check_balance.valid?
          domains.each do |domain|
            Domains::BulkRenew::SingleDomainRenew.run(domain: domain,
                                                      period: period,
                                                      unit: unit,
                                                      registrar: registrar)
          end
        else
          errors.merge!(mass_check_balance.errors)
        end
      end

      private

      def period
        period_element.to_i.zero? ? 1 : period_element.to_i
      end

      def unit
        period_element[-1] || 'y'
      end

      def mass_check_balance
        Domains::CheckBalance::Mass.run(domains: domains,
                                        operation: 'renew',
                                        period: period,
                                        unit: unit)
      end
    end
  end
end
