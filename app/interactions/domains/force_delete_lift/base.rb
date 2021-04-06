module Domains
  module ForceDeleteLift
    class Base < ActiveInteraction::Base
      object :domain,
             class: Domain,
             description: 'Domain to check if ForceDelete needs to be listed'

      def execute
        prepare_email_verifications(domain)

        lift_force_delete(domain) if force_delete_condition(domain)
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

      def prepare_email_verifications(domain)
        domain.registrant.email_verification.verify
        domain.contacts.each { |contact| contact.email_verification.verify }
      end
    end
  end
end
