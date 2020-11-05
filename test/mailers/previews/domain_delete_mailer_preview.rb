class DomainDeleteMailerPreview < ActionMailer::Preview
  def self.define_forced_templates
    %w[private_person legal_person invalid_email].each do |template_name|
      define_method "forced_#{template_name}".to_sym do
        DomainDeleteMailer.forced(domain: @domain,
                                  registrar: @domain.registrar,
                                  registrant: @domain.registrant,
                                  template_name: template_name)
      end
    end
  end

  define_forced_templates

  def initialize
    @domain = Domain.first
    super
  end

  def confirmation_request
    DomainDeleteMailer.confirmation_request(domain: @domain,
                                            registrar: @domain.registrar,
                                            registrant: @domain.registrant)
  end

  def accepted
    DomainDeleteMailer.accepted(@domain)
  end

  def rejected
    DomainDeleteMailer.rejected(@domain)
  end

  def expired
    DomainDeleteMailer.expired(@domain)
  end
end
