class DomainExpireEmailJob < Que::Job
  def run(domain_id)
    domain = Domain.find(domain_id)

    return if domain.registered?

    log(domain)
    DomainExpireMailer.expired(domain: domain, registrar: domain.registrar).deliver_now
  end

  private

  def log(domain)
    Rails.logger.info("Send DomainExpireMailer#expired email for domain ##{domain.id} to #{domain.primary_contact_emails.join(', ')}")
  end
end
