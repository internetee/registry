module Domains
  module ForceDeleteEmail
    # Processes domains with invalid emails by flagging them for force deletion
    # when email addresses are identified as invalid or bouncing
    class Base < ActiveInteraction::Base
      string :email,
             description: 'Bounced email to set ForceDelete from'

      def execute
        # Return early if no affected domains or if any domains are on hold
        affected_domains = find_affected_domains
        return if should_skip_processing?(affected_domains)

        process_affected_domains(affected_domains)
      end

      private

      def should_skip_processing?(domains)
        domains.empty? || domains_on_hold_exist?(domains)
      end

      def process_affected_domains(domains)
        domains.each do |domain|
          next if domain.expired?

          process_domain_for_force_delete(domain)
        end
      end

      def find_affected_domains
        # Find domains through contacts
        contact_domains = Contact.where(email: email).flat_map(&:domain_contacts)
                                 .flat_map(&:domain)

        # Find domains through registrants
        registrant_domains = Domain.where(registrant_id: Registrant.where(email: email).select(:id))

        # Combine and remove duplicates
        (contact_domains + registrant_domains).uniq
      end

      def domains_on_hold_exist?(domains)
        domains.any? do |domain|
          domain.statuses.include?(DomainStatus::SERVER_HOLD) && email.include?(domain.name)
        end
      end

      def process_domain_for_force_delete(domain)
        if domain.force_delete_scheduled? && domain.status_notes[DomainStatus::FORCE_DELETE].present?
          add_email_to_notes(domain)
        else
          schedule_force_delete(domain)
        end
      end

      def notify_registrar(domain)
        template = I18n.t('force_delete_auto_email',
                          domain_name: domain.name,
                          outzone_date: domain.outzone_date,
                          purge_date: domain.purge_date,
                          email: domain.status_notes[DomainStatus::FORCE_DELETE])

        return if domain.registrar.notifications.last&.text&.include?(template)

        domain.registrar.notifications.create!(text: template)
      end

      def schedule_force_delete(domain)
        domain.schedule_force_delete(
          type: :soft,
          notify_by_email: true,
          reason: 'invalid_email',
          email: email
        )
      end

      def add_email_to_notes(domain)
        return if domain.status_notes[DomainStatus::FORCE_DELETE].include?(email)

        # Uncomment if notification is needed
        # notify_registrar(domain)

        domain.status_notes[DomainStatus::FORCE_DELETE].concat(" #{email}")
        domain.save(validate: false)
      end
    end
  end
end
