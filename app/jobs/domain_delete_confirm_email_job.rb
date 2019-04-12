class DomainDeleteConfirmEmailJob < Que::Job
  def run(domain_id)
    domain = Domain.find(domain_id)

    log(domain)
    DomainDeleteMailer.confirmation_request(domain: domain,
                                            registrar: domain.registrar,
                                            registrant: domain.registrant).deliver_now
  end

  private

  def log(domain)
    message = "Send DomainDeleteMailer#confirm email for domain #{domain.name} (##{domain.id})" \
    " to #{domain.registrant.email}"
    logger.info(message)
  end

  def logger
    Rails.logger
  end
end
