class DomainExpireEmailJob < Que::Job
  def run(domain_id)
    domain = Domain.find(domain_id)

    return if domain.registered?

    log(domain)
    DomainExpireMailer.expired(domain: domain, registrar: domain.registrar).deliver_now
  end

  private

  def log(domain)
    message = "Send DomainExpireMailer#expired email for domain ##{domain.id} to #{domain.primary_contact_emails.join(', ')}"
    logger.info(message)
  end

  def logger
    Rails.logger
  end
end
