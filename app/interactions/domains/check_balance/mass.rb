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

          if task.valid?
            @total_price += task.result
          else
            task.errors.each { |task_error| errors.import task_error }
          end
        end
      end
    end
  end
end
