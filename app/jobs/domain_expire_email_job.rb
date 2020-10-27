class DomainExpireEmailJob < ApplicationJob
  queue_as :default

  def perform(domain_id)
    domain = Domain.find(domain_id)

    return if domain.registered?

    DomainExpireMailer.expired(domain: domain, registrar: domain.registrar).deliver_now
  end
end
