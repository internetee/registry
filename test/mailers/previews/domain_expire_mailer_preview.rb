class DomainExpireMailerPreview < ActionMailer::Preview
  def expired
    domain = Domain.first
    DomainExpireMailer.expired(domain: domain,
                               registrar: domain.registrar)
  end
end