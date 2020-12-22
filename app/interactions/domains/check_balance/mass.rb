module Domains
  module CheckBalance
    class Mass < ActiveInteraction::Base
      array :domains do
        object class: Epp::Domain
      end
      string :operation
      integer :period
      string :unit
      float :balance

      attr_accessor :total_price

      def execute
        calculate_total_price

        balance >= @total_price
      end

      def calculate_total_price
        @total_price = 0
        domains.each do |domain|
          task = Domains::CheckBalance::SingleDomain.run(domain: domain,
                                                         operation: 'renew',
                                                         period: period,
                                                         unit: unit)

          task.valid? ? @total_price += task.result : errors.merge!(task.errors)
        end
      end
    end
  end
end
