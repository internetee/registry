module Domains
  module ForceDeleteBounce
    class Base < ActiveInteraction::Base
      object :bounced_mail_address,
             class: BouncedMailAddress,
             description: 'Bounced email to set ForceDelete from'

      def execute
        email = bounced_mail_address.email
        domain_contacts = Contact.where(email: email).map(&:domain_contacts).flatten
        domains = domain_contacts.map(&:domain).flatten
        domains.each do |domain|
          domain.schedule_force_delete(type: :soft,
                                       notify_by_email: true, reason: 'invalid_email')
        end
      end
    end
  end
end
