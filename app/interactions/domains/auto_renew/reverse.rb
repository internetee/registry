module Domains
  module AutoRenew
    class Reverse < Base
      object :domain, class: Domain
      object :registrar, class: Registrar
      string :cycle_id

      def execute
        with_locks(domain: domain) do
          next command_error(2201, :not_sponsor) unless domain.registrar_id == registrar.id

          cycle = domain.auto_renewals.find_by(uuid: cycle_id)
          next command_error(2303, :unknown_cycle, cycle_id) unless cycle
          cycle.lock!
          next build_result(cycle, true) if cycle.reversed?
          next command_error(2304, :not_reversible, cycle_id) unless cycle.reversible?

          cycle.account.lock!
          next command_error(2304, :not_reversible, cycle_id) unless cycle.reversible?
          domain.valid_to = if domain.valid_to == cycle.renewed_expire_at
                              cycle.original_expire_at
                            else
                              domain.valid_to.advance(years: -DomainAutoRenewal::RENEWAL_PERIOD_YEARS)
                            end
          domain.auto_renew = false
          domain.save!(validate: false)
          # Restored expiry already passed: run the ordinary expiry step (statuses, dates, emails).
          Domains::ExpirePeriod::ProcessExpired.run!(domain: domain) if domain.expired?
          charge = cycle.charge_activity
          refund = cycle.account.account_activities.create!(
            sum: -charge.sum, currency: charge.currency, price: charge.price,
            description: I18n.t('auto_renew.activity.refund', domain: cycle.domain_name),
            activity_type: AccountActivity::REFUND
          )
          cycle.update!(state: DomainAutoRenewal::REVERSED, refund_activity: refund, closed_at: Time.zone.now)
          build_result(cycle, false)
        end
      end

      private

      def build_result(cycle, repeated)
        ChangeResult.new(enabled: domain.auto_renew?, reversed_cycle: cycle,
                         refund_activity: cycle.refund_activity, already_reversed: repeated)
      end
    end
  end
end
