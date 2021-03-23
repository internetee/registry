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

        return unless saved

        recipients.each do |recipient|
          DomainExpireEmailJob.enqueue(domain.id, recipient, run_at: send_time)
        end
      end

      def set_graceful_expired
        domain.outzone_at = domain.expire_time + Domain.expire_warning_period
        domain.delete_date = domain.outzone_at + Domain.redemption_grace_period
        domain.statuses |= [DomainStatus::EXPIRED]
      end

      def send_time
        domain.valid_to + Setting.expiration_reminder_mail.to_i.days
      end

      def recipients
        filter_invalid_emails(domain.expired_domain_contact_emails)
      end

      def filter_invalid_emails(emails)
        emails.select do |email|
          valid = Truemail.valid?(email)

          unless valid
            logger.info('Unable to send DomainExpireMailer#expired email for'\
                        "domain #{domain.name} (##{domain.id}) to invalid recipient #{email}")
          end

          valid
        end
      end
    end
  end
end
