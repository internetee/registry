class DomainDeleteForcedEmailJob < Que::Job
  def run(domain_id, template_name)
    domain = Domain.find(domain_id)

    log(domain)
    DomainDeleteMailer.forced(domain: domain,
                              registrar: domain.registrar,
                              registrant: domain.registrant,
                              template_name: template_name).deliver_now
  end

  private

  def log(domain)
    message = "Send DomainDeleteMailer#forced email for domain #{domain.name} (##{domain.id})" \
    " to #{domain.primary_contact_emails.join(', ')}"
    logger.info(message)
  end

  def logger
    Rails.logger
  end
end
