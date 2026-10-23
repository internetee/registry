module Domains
  module AutoRenew
    class CloseCycle < Base
      object :cycle, class: DomainAutoRenewal

      def execute
        domain = Domain.find_by(id: cycle.domain_id)
        with_locks(domain: domain, cycle: cycle) do
          next cycle unless cycle.open? && Time.zone.now >= cycle.cancellation_deadline_at

          if cycle.grace?
            cycle.update!(state: DomainAutoRenewal::COMPLETED, closed_at: Time.zone.now)
          elsif domain.nil? || domain.registrar_id != cycle.registrar_id || !domain.auto_renew? ||
                domain.valid_to != cycle.original_expire_at
            cancel(cycle)
          else
            cycle.update!(state: DomainAutoRenewal::FAILED, closed_at: Time.zone.now)
            notify(cycle, :renewal_failed)
          end
          cycle
        end
      end
    end
  end
end
