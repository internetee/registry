class DomainExpireMailerPreview < ActionMailer::Preview
  def expired
    domain = Domain.first
    DomainExpireMailer.expired(domain: domain,
                               registrar: domain.registrar)
  end

  def expired_soft
    domain = Domain.first
    DomainExpireMailer.expired_soft(domain: domain,
                                    registrar: domain.registrar)
  end
end
