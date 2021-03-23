class DomainExpireEmailJob < Que::Job
  def run(domain_id, email)
    domain = Domain.find(domain_id)

    return if domain.registered?

    attrs = {
      domain: domain,
      registrar: domain.registrar,
      email: email,
    }

    if domain.force_delete_scheduled?
      DomainExpireMailer.expired_soft(attrs).deliver_now
    else
      DomainExpireMailer.expired(attrs).deliver_now
    end
  end
end
