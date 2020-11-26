module DomainUpdateConfirmInteraction
  class Base < ActiveInteraction::Base
    object :domain,
           class: Domain,
           description: 'Domain to confirm update'
    string :action
    string :initiator,
           default: nil

    validates :domain, :action, presence: true
    validates :action, inclusion: { in: [RegistrantVerification::CONFIRMED,
                                         RegistrantVerification::REJECTED] }

    def raise_errors!(domain)
      return unless domain.errors.any?

      message = "domain #{domain.name} failed with errors #{domain.errors.full_messages}"
      throw message
    end

    def notify_registrar(message_key)
      domain.registrar.notifications.create!(
        text: "#{I18n.t(message_key)}: #{domain.name}",
        attached_obj_id: domain.id,
        attached_obj_type: domain.class.to_s
      )
    end
  end
end
