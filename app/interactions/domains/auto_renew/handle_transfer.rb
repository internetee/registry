module Domains
  module AutoRenew
    class HandleTransfer < Base
      object :domain, class: Domain

      def execute
        # Use a fresh instance so the after_save hook preserves the caller's saved changes.
        current_domain = Domain.find(domain.id)
        with_locks(domain: current_domain) do
          current_domain.auto_renewals.open_cycles.each do |cycle|
            cycle.lock!
            next unless cycle.open? && cycle.registrar_id != current_domain.registrar_id

            state = cycle.grace? ? DomainAutoRenewal::COMPLETED : DomainAutoRenewal::CANCELLED
            cycle.update!(state: state, closed_at: Time.zone.now)
          end
        end
      end
    end
  end
end
