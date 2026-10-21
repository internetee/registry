module Domains
  module AutoRenew
    class OpenCycle < Base
      object :domain, class: Domain

      def execute
        with_locks(domain: domain) do
          next unless Feature.auto_renew_enabled? && domain.auto_renew?
          now = Time.zone.now
          deadline = DomainAutoRenewal.cancellation_deadline_for(domain.valid_to)
          next unless domain.valid_to <= now

          existing = domain.auto_renewals.find_by(original_expire_at: domain.valid_to)
          next existing if existing
          next if domain.auto_renewals.open_cycles.exists?

          domain.auto_renewals.create!(domain_name: domain.name, registrar: domain.registrar,
                                     account: domain.registrar.cash_account,
                                     original_expire_at: domain.valid_to,
                                     cancellation_deadline_at: deadline).reload
        end
      rescue ActiveRecord::RecordNotUnique
        domain.auto_renewals.find_by(original_expire_at: domain.reload.valid_to)
      end
    end
  end
end
