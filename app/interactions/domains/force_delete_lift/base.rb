module Domains
  module ForceDeleteLift
    class Base < ActiveInteraction::Base
      object :domain,
             class: Domain,
             description: 'Domain to check if ForceDelete needs to be listed'

      def execute
        lift_force_delete(domain) if force_delete_condition(domain)
      end

      private

      def lift_force_delete(domain)
        domain.cancel_force_delete
      end

      def force_delete_condition(domain)
        domain.force_delete_scheduled? &&
          template_of_invalid_email?(domain) &&
          contact_emails_valid?(domain) &&
          bounces_absent?(domain)
      end

      def template_of_invalid_email?(domain)
        domain.template_name == 'invalid_email'
      end

      def contact_emails_valid?(domain)
        flag = nil
        domain.contacts do |c|
          flag = c.need_to_lift_force_delete?
          return flag unless flag
        end

        flag && domain.registrant.need_to_lift_force_delete?
      end

      def bounces_absent?(domain)
        emails = domain.all_related_emails
        BouncedMailAddress.where(email: emails).empty?
      end
    end
  end
end
