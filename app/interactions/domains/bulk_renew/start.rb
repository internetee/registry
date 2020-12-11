module Domains
  module BulkRenew
    class Start < ActiveInteraction::Base
      array :domains do
        object class: Epp::Domain
      end
      string :period_element

      def execute
        period = (period_element.to_i == 0) ? 1 : period_element.to_i
        unit = period_element[-1] || 'y'
        task = Domains::CheckBalance::Mass.run(domains: domains,
                                               operation: 'renew',
                                               period: period,
                                               unit: unit)
        unless task.valid?
          errors.merge!(task.errors)
        end
      end
    end
  end
end
