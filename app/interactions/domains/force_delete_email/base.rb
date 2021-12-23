module Domains
  module ForceDeleteEmail
    class Base < ActiveInteraction::Base
      string :email,
             description: 'Bounced email to set ForceDelete from'

      def execute
        domain_contacts = Contact.where(email: email).map(&:domain_contacts).flatten
        registrant_ids = Registrant.where(email: email).pluck(:id)

        domains = domain_contacts.map(&:domain).flatten +
                  Domain.where(registrant_id: registrant_ids)

        domains.each do |domain|
          next if domain.expired?

          before_execute_force_delete(domain)
        end
      end

      private

      def before_execute_force_delete(domain)
        if domain.force_delete_scheduled? && !domain.status_notes[DomainStatus::FORCE_DELETE].nil?
          added_additional_email_into_notes(domain)
        else
          process_force_delete(domain)
        end
      end

      def process_force_delete(domain)
        domain.schedule_force_delete(type: :soft,
                                     notify_by_email: true,
                                     reason: 'invalid_email',
                                     email: email)
        save_status_note(domain)
      end

      def added_additional_email_into_notes(domain)
        return if domain.status_notes[DomainStatus::FORCE_DELETE].include? email

        domain.status_notes[DomainStatus::FORCE_DELETE].concat(" #{email}")
        domain.save(validate: false)
      end

      def save_status_note(domain)
        domain.status_notes[DomainStatus::FORCE_DELETE] = email
        domain.save(validate: false)
      end
    end
  end
end
