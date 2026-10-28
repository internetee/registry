module Domains
  module ExpirePeriod
    class ProcessExpired < Base
      object :domain,
             class: Domain,
             description: 'Domain to set expiration'

      def execute
        Domain.transaction do
          domain.reload(lock: true)
          next unless domain.expirable?
          next if self.class.waiting_for_auto_renew?(domain)

          set_graceful_expired
          to_stdout("start_expire_period: ##{domain.id} (#{domain.name}) #{domain.changes}")

          saved = domain.save(validate: false)

          next unless saved

          recipients.each do |recipient|
            DomainExpireEmailJob.set(wait_until: send_time).perform_later(domain.id, recipient)
          end
        end
      end

      def self.waiting_for_auto_renew?(domain)
        domain.auto_renew? && Feature.auto_renew_enabled? &&
          Time.zone.now < DomainAutoRenewal.cancellation_deadline_for(domain.valid_to) &&
          !domain.auto_renewals.exists?(original_expire_at: domain.valid_to)
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
            logger.info('Unable to send DomainExpireMailer#expired email for '\
                        "domain #{domain.name} (##{domain.id}) to invalid recipient #{email}")
          end

          valid
        end
      end
    end
  end
end
