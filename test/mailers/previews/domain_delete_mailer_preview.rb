class DomainDeleteMailerPreview < ActionMailer::Preview
  def self.define_forced_templates
    %w[private_person legal_person invalid_email].each do |template_name|
      define_method "forced_#{template_name}".to_sym do
        domain = Domain.first
        DomainDeleteMailer.forced(domain: domain,
                                  registrar: domain.registrar,
                                  registrant: domain.registrant,
                                  template_name: template_name)
      end
    end
  end

  define_forced_templates

  def confirmation_request
    domain = Domain.first
    DomainDeleteMailer.confirmation_request(domain: domain,
                                            registrar: domain.registrar,
                                            registrant: domain.registrant)
  end

  def accepted
    domain = Domain.first
    DomainDeleteMailer.accepted(domain)
  end

  def rejected
    domain = Domain.first
    DomainDeleteMailer.rejected(domain)
  end

  def expired
    domain = Domain.first
    DomainDeleteMailer.expired(domain)
  end
end
