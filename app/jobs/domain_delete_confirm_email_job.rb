class DomainDeleteConfirmEmailJob < Que::Job
  def run(domain_id)
    domain = Domain.find(domain_id)

    DomainDeleteMailer.confirm(domain: domain,
                               registrar: domain.registrar,
                               registrant: domain.registrant).deliver_now
  end
end
