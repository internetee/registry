module Domains
  module AutoRenew
    # Callers must lock the domain in their transaction before assigning any changes.
    class ChangePreference < Base
      object :domain, class: Domain
      object :registrar, class: Registrar
      boolean :enabled, default: nil
      string :reverse_cycle_id, default: nil

      def execute
        Domain.transaction(requires_new: false) do
          next command_error(2201, :not_sponsor) unless domain.registrar_id == registrar.id
          if enabled == true && reverse_cycle_id.present?
            next command_error(2306, :enable_and_reverse)
          end
          if enabled == true && !Feature.auto_renew_enabled?
            next command_error(2306, :unavailable)
          end

          if reverse_cycle_id.present?
            outcome = Reverse.run(domain: domain, registrar: registrar, cycle_id: reverse_cycle_id)
            errors.merge!(outcome.errors) unless outcome.valid?
            next outcome.result
          end

          unless enabled.nil?
            if enabled == false
              domain.auto_renewals.awaiting_funds.each do |cycle|
                cycle.lock!
                cancel(cycle) if cycle.awaiting_funds?
              end
            end
            domain.auto_renew = enabled
            domain.save!(validate: false)
          end
          ChangeResult.new(enabled: domain.auto_renew?, already_reversed: false)
        end
      end
    end
  end
end
