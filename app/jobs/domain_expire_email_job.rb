class DomainExpireEmailJob < ApplicationJob
  def perform(domain_id, email)
    domain = Domain.find_by(id: domain_id)

    return if domain.blank?
    return if domain.registered?

    attrs = {
      domain: domain,
      registrar: domain.registrar,
      email: email,
    }

    if domain.force_delete_scheduled?
      DomainExpireMailer.expired_soft(**attrs).deliver_now
    else
      DomainExpireMailer.expired(**attrs).deliver_now
    end
  end
end
