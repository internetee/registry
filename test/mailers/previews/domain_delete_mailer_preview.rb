class DomainDeleteMailerPreview < ActionMailer::Preview
  def self.define_forced_templates
    DomainDeleteMailer.force_delete_templates.each do |template_name|
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

  def confirmation
    domain = Domain.first
    DomainDeleteMailer.confirmation(domain: domain,
                                    registrar: domain.registrar,
                                    registrant: domain.registrant)
  end
end