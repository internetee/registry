class DomainExpireEmailJob < Que::Job
  def run(domain_id)
    domain = Domain.find(domain_id)

    return if domain.registered?

    if domain.force_delete_scheduled?
      DomainExpireMailer.expired_soft(domain: domain, registrar: domain.registrar).deliver_now
    else
      DomainExpireMailer.expired(domain: domain, registrar: domain.registrar).deliver_now
    end
  end
end
