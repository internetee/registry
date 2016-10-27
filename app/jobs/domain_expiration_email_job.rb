class DomainExpirationEmailJob < ActiveJob::Base
  queue_as :default

  def perform(domain_id:)
    domain = Domain.find(domain_id)

    return if domain.registered?

    DomainMailer.expiration(domain).deliver!
  end
end
