module Domains
  module ForceDelete
    class NotifyMultiyearsExpirationDomain < Base
      SCHEDULED_DATA = 2.days
      MULTIYEAR_VALUE_START_LIMIT = 1.year

      def execute
        return unless multiyear_registrations?

        recipients.each do |recipient|
          DomainExpireEmailJob.set(wait_until: send_time).perform_later(domain.id, recipient, multiyears_expiration: true)
        end
      end

      def send_time
        domain.force_delete_start + SCHEDULED_DATA
      end

      def multiyear_registrations?
        domain_expire = domain.valid_to.to_i
        current_time = Time.zone.now.to_i

        (domain_expire - current_time) >= MULTIYEAR_VALUE_START_LIMIT.to_i
      end

      def recipients
        filter_invalid_emails(domain.expired_domain_contact_emails)
      end

      def filter_invalid_emails(emails)
        emails.select do |email|
          valid = Rails.env.test? ? true : Truemail.valid?(email)

          unless valid
            Rails.logger.info('Unable to send DomainExpireMailer#expired email for '\
                        "domain #{domain.name} (##{domain.id}) to invalid recipient #{email}")
          end

          valid
        end
      end
    end
  end
end
