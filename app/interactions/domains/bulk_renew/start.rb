module Domains
  module BulkRenew
    class Start < ActiveInteraction::Base
      array :domains do
        object class: Epp::Domain
      end
      string :period_element
      object :registrar

      def execute
        if renewable?
          domains.each do |domain|
            task = run_task(domain)
            manage_errors(task)
          end
        else
          manage_errors(mass_check_balance)
        end
      end

      private

      def renewable?
        mass_check_balance.valid? && mass_check_balance.result
      end

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
                                        unit: unit,
                                        balance: registrar.balance)
      end

      def manage_errors(task)
        task.errors.each { |k, v| errors.add(k, v) } unless task.valid?
        errors.add(:domain, I18n.t('not_enough_funds')) unless task.result
      end

      def run_task(domain)
        Domains::BulkRenew::SingleDomainRenew.run(domain: domain,
                                                  period: period,
                                                  unit: unit,
                                                  registrar: registrar)
      end
    end
  end
end
