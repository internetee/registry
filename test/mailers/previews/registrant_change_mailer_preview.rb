class RegistrantChangeMailerPreview < ActionMailer::Preview
  def initialize
    @domain = Domain.first
    @new_registrant = Registrant.where.not(email: nil, country_code: nil).first
    super
  end

  def confirmation_request
    RegistrantChangeMailer.confirmation_request(domain: @domain,
                                                registrar: @domain.registrar,
                                                current_registrant: @domain.registrant,
                                                new_registrant: @new_registrant)
  end

  def notification
    RegistrantChangeMailer.notification(domain: @domain,
                                        registrar: @domain.registrar,
                                        current_registrant: @domain.registrant,
                                        new_registrant: @new_registrant)
  end

  def accepted
    RegistrantChangeMailer.accepted(domain: @domain,
                                    old_registrant: @domain.registrar)
  end

  def rejected
    RegistrantChangeMailer.rejected(domain: @domain,
                                    registrar: @domain.registrar,
                                    registrant: @domain.registrant)
  end

  def expired
    RegistrantChangeMailer.expired(domain: @domain,
                                   registrar: @domain.registrar,
                                   registrant: @domain.registrant)
  end
end