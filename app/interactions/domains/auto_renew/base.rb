module Domains
  module AutoRenew
    class Base < ActiveInteraction::Base
      MAX_TRANSACTION_ATTEMPTS = 3

      def logger
        @logger ||= Logger.new(Rails.root.join('log/domain_auto_renew.log'))
      end

      private

      # A deadlock or serialization failure aborts the whole database transaction, and Rails
      # discards the connection when it happens inside a savepoint. A retry is therefore only
      # safe when this block owns the outermost transaction (cron); nested callers re-raise.
      def with_locks(domain:, cycle: nil)
        retryable = !Domain.connection.transaction_open?
        attempts = 0
        begin
          attempts += 1
          Domain.transaction(requires_new: true) do
            domain&.reload(lock: true)
            cycle&.reload(lock: true)
            yield
          end
        rescue ActiveRecord::SerializationFailure, ActiveRecord::Deadlocked
          retry if retryable && attempts < MAX_TRANSACTION_ATTEMPTS
          raise
        end
      end

      def cancel(cycle)
        cycle.update!(state: DomainAutoRenewal::CANCELLED, closed_at: Time.zone.now)
      end

      def notify(cycle, event)
        amount = cycle.charge_activity&.sum&.abs || cycle.price&.price&.amount
        cycle.registrar.notifications.create!(
          text: I18n.t("auto_renew.notifications.#{event}", domain: cycle.domain_name,
                       expire_date: (cycle.renewed_expire_at || cycle.original_expire_at).iso8601,
                       amount: amount ? format('%.2f', amount) : '-', cycle_id: cycle.uuid,
                       deadline: cycle.cancellation_deadline_at.iso8601,
                       reason: I18n.t("auto_renew.failure_reasons.#{cycle.failure_reason || 'not_attempted'}")),
          event: event.to_s.camelize(:lower),
          attached_obj_type: 'DomainAutoRenewal', attached_obj_id: cycle.id
        )
      end

      def command_error(code, key, value = nil)
        message = I18n.t("auto_renew.errors.#{key}")
        # REPP may supply a base Domain rather than an Epp::Domain.
        domain.extend(EppErrors) unless domain.respond_to?(:add_epp_error)
        domain.add_epp_error(code, 'autoRenew', value, message)
        errors.add(:base, message)
        nil
      end
    end
  end
end
