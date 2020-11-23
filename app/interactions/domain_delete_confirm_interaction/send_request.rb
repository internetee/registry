module DomainDeleteConfirmInteraction
  class SendRequest < ActiveInteraction::Base
    object :domain,
           class: Domain,
           description: 'Domain to send delete confirmation'

    def execute
      log
      DomainDeleteMailer.confirmation_request(domain: domain,
                                              registrar: domain.registrar,
                                              registrant: domain.registrant).deliver_now
    end

    private

    def log
      message = "Send DomainDeleteMailer#confirm email for domain #{domain.name} (##{domain.id})" \
    " to #{domain.registrant.email}"
      Rails.logger.info(message)
    end
  end
end
