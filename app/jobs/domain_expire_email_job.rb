class DomainExpireEmailJob < ApplicationJob
  def perform(domain_id, email, multiyears_expiration: false)
    domain = Domain.find_by(id: domain_id)

    return if domain.blank?
    return if domain.registered? && !domain.force_delete_scheduled?

    attrs = {
      domain: domain,
      registrar: domain.registrar,
      email: email,
    }

    if domain.force_delete_scheduled?
      if multiyears_expiration
        DomainExpireMailer.notify_soft_violation(**attrs).deliver_now
      else
        DomainExpireMailer.expired_soft(**attrs).deliver_now
      end
    else
      DomainExpireMailer.expired(**attrs).deliver_now
    end
  end
end
