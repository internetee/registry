module Domains
  module BulkRenew
    class SingleDomainRenew < ActiveInteraction::Base
      object :domain,
             class: Epp::Domain
      integer :period
      string :unit
      object :registrar

      def execute
        renewed_expire_time = prepare_renewed_expire_time
        in_transaction_with_retries do
          check_balance
          success = domain.renew(renewed_expire_time, period, unit)
          if success
            check_balance
            reduce_balance
          else
            add_error
          end
        end
      end

      def check_balance
        compose(Domains::CheckBalance::SingleDomain,
                domain: domain,
                operation: 'renew',
                period: period,
                unit: unit)
      end

      def reduce_balance
        domain_pricelist = domain.pricelist('renew', period, unit)
        registrar.debit!(sum: domain_pricelist.price.amount,
                         description: "#{I18n.t('renew')} #{domain.name}",
                         activity_type: AccountActivity::RENEW,
                         price: domain_pricelist)
      end

      def in_transaction_with_retries
        if Rails.env.test?
          yield
        else
          transaction_wrapper { yield }
        end
      rescue ActiveRecord::StatementInvalid => e
        log_error e
        sleep rand / 100
        retry
      end

      def transaction_wrapper
        ActiveRecord::Base.transaction(isolation: :serializable) do
          yield if block_given?
        end
      end

      private

      def add_error
        domain.add_epp_error(2104, nil, nil, I18n.t(:domain_renew_error_for_domain))
        errors.add(:domain, I18n.t('domain_renew_error_for_domain', domain: domain.name))
      end

      def prepare_renewed_expire_time
        int_period = period.to_i
        plural_period_unit_name = (unit == 'm' ? 'months' : 'years').to_sym
        renewed_expire_time = domain.valid_to.advance(plural_period_unit_name => int_period.to_i)

        max_reg_time = 11.years.from_now

        if renewed_expire_time >= max_reg_time
          domain.add_epp_error('2105', nil, nil,
                               I18n.t('epp.domains.object_is_not_eligible_for_renewal',
                                      max_date: max_reg_time.to_date.to_s(:db)))
        end
        renewed_expire_time
      end

      def log_error(error)
        message = (["#{self.class} - #{error.class}: #{error.message}"] + error.backtrace)
                  .join("\n")
        Rails.logger.error message
      end
    end
  end
end
