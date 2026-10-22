module Domains
  module AutoRenew
    class HandleRegistrantChange < Base
      object :domain, class: Domain

      def execute
        previous_registrant = Contact.find_by(id: domain.registrant_id_before_last_save)
        return unless previous_registrant

        # Use a fresh instance so the after_save hook preserves the caller's saved changes.
        current_domain = Domain.find(domain.id)
        with_locks(domain: current_domain) do
          next if previous_registrant.ident == current_domain.registrant.ident

          current_domain.auto_renewals.in_grace.each do |cycle|
            cycle.lock!
            next unless cycle.grace?

            cycle.update!(state: DomainAutoRenewal::COMPLETED, closed_at: Time.zone.now)
          end
        end
      end
    end
  end
end
