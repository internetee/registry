module Domains
  module CheckBalance
    class Mass < ActiveInteraction::Base
      array :domains do
        object class: Epp::Domain
      end
      string :operation
      integer :period
      string :unit

      def execute
        domains.each do |domain|
          compose(Domains::CheckBalance::SingleDomain,
                  domain: domain,
                  operation: 'renew',
                  period: period,
                  unit: unit)
        end
      end
    end
  end
end
