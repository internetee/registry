module Domains
  module AutoRenew
    class AttemptRenewal < Base
      object :cycle, class: DomainAutoRenewal

      def execute
        domain = Domain.find_by(id: cycle.domain_id)
        with_locks(domain: domain, cycle: cycle) do
          next cycle unless cycle.awaiting_funds?

          cycle.attempts_count += 1
          cycle.last_attempt_at = Time.zone.now
          if domain.nil? || domain.registrar_id != cycle.registrar_id || !domain.auto_renew? ||
             domain.valid_to != cycle.original_expire_at
            cancel(cycle)
          else
            attempt(domain)
          end
          cycle
        end
      end

      private

      def attempt(domain)
        if domain.renew_blocking_statuses.any? || domain.statuses.include?(DomainStatus::PENDING_DELETE)
          return failure(DomainAutoRenewal::RENEW_PROHIBITED, :blocked_warning_sent_at, :renew_prohibited)
        end

        cycle.price = domain.pricelist('renew', 1, 'y', at: cycle.original_expire_at)
        unless cycle.price
          logger.error("Missing automatic renewal price for #{cycle.domain_name} (#{cycle.uuid})")
          return failure(DomainAutoRenewal::MISSING_PRICE, :blocked_warning_sent_at, :renew_prohibited)
        end

        account = cycle.account
        account.lock!

        unless account.registrar_id == cycle.registrar_id && cycle.registrar.cash_account&.id == account.id
          raise ActiveRecord::RecordNotFound, "Automatic renewal payer account changed for cycle #{cycle.uuid}"
        end
        if account.balance < cycle.price.price.amount
          return failure(DomainAutoRenewal::INSUFFICIENT_FUNDS, :funding_warning_sent_at, :funding_warning)
        end

        cycle.charge_activity = cycle.registrar.debit!(
          sum: cycle.price.price.amount, price: cycle.price,
          description: I18n.t('auto_renew.activity.renew', domain: cycle.domain_name),
          activity_type: AccountActivity::RENEW
        )
        cycle.renewed_expire_at = cycle.original_expire_at.advance(years: DomainAutoRenewal::RENEWAL_PERIOD_YEARS)
        domain.assign_renewal_expiry(cycle.renewed_expire_at)
        domain.save!(validate: false)
        renewed_at = Time.zone.now
        completed = renewed_at >= cycle.cancellation_deadline_at
        cycle.update!(state: completed ? DomainAutoRenewal::COMPLETED : DomainAutoRenewal::GRACE,
                      renewed_at: renewed_at, closed_at: completed ? renewed_at : nil, failure_reason: nil)
        notify(cycle, :renewed)
      end

      def failure(reason, warning_attribute, event)
        cycle.failure_reason = reason
        unless cycle.public_send(warning_attribute)
          cycle.public_send("#{warning_attribute}=", Time.zone.now)
          notify(cycle, event)
        end
        cycle.save!
      end
    end
  end
end
