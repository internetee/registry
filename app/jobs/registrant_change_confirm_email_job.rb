class RegistrantChangeConfirmEmailJob < Que::Job
  def run(domain_id, new_registrant_id)
    domain = Domain.find(domain_id)
    new_registrant = Registrant.find(new_registrant_id)

    log(domain)
    RegistrantChangeMailer.confirm(domain: domain,
                                   registrar: domain.registrar,
                                   current_registrant: domain.registrant,
                                   new_registrant: new_registrant).deliver_now
  end

  private

  def log(domain)
    message = "Send RegistrantChangeMailer#confirm email for domain #{domain.name} (##{domain.id}) to #{domain.registrant_email}"
    logger.info(message)
  end

  def logger
    Rails.logger
  end
end
