class DomainExpirationEmailJob < Que::Job
  def run(domain_id:)
    domain = Domain.find(domain_id)

    return if domain.registered?

    DomainMailer.expiration(domain: domain).deliver
    destroy
  end
end
