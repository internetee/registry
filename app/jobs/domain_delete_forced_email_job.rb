class DomainDeleteForcedEmailJob < Que::Job
  def run(domain_id)
    domain = Domain.find(domain_id)

    log(domain)
    DomainDeleteMailer.forced(domain: domain,
                              registrar: domain.registrar,
                              registrant: domain.registrant).deliver_now
  end

  private

  def log(domain)
    message = "Send DomainDeleteMailer#forced email for domain ##{domain.id} to #{domain.primary_contact_emails
                                                                                    .join(', ')}"
    logger.info(message)
  end

  def logger
    Rails.logger
  end
end
