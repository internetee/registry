module Domains
  module ExpirePeriod
    class ProcessExpired < Base
      object :domain,
             class: Domain,
             description: 'Domain to set expiration'

      def execute
        set_graceful_expired
        to_stdout("start_expire_period: ##{domain.id} (#{domain.name}) #{domain.changes}")

        saved = domain.save(validate: false)

        DomainExpireEmailJob.enqueue(domain.id, run_at: send_time) if saved
      end

      def set_graceful_expired
        domain.outzone_at = domain.expire_time + Domain.expire_warning_period
        domain.delete_date = domain.outzone_at + Domain.redemption_grace_period
        domain.statuses |= [DomainStatus::EXPIRED]
      end

      def send_time
        domain.valid_to + Setting.expiration_reminder_mail.to_i.days
      end
    end
  end
end
