module Domains
  module ForceDeleteLift
    class Base < ActiveInteraction::Base
      string :email,
             description: 'Email to check if ForceDelete needs to be lifted'

      def execute
        domain_contacts = Contact.where(email: email).map(&:domain_contacts).flatten
        registrant_ids = Registrant.where(email: email).pluck(:id)

        domains = domain_contacts.map(&:domain).flatten +
          Domain.where(registrant_id: registrant_ids)

        domains.each { |domain| lift_force_delete(domain) if force_delete_condition(domain) }
      end

      private

      def lift_force_delete(domain)
        domain.cancel_force_delete
      end

      def force_delete_condition(domain)
        domain.force_delete_scheduled? &&
          domain.template_name == 'invalid_email' &&
          domain.contacts.all? { |contact| contact.email_verification.verified? } &&
          domain.registrant.email_verification.verified?
      end
    end
  end
end
