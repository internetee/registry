class RegistrantChangeMailerPreview < ActionMailer::Preview
  def initialize
    @domain = Domain.first
    @new_registrant = Registrant.where.not(email: nil, country_code: nil).first
    super
  end

  def confirmation_request
    RegistrantChangeMailer.confirm(domain: @domain,
                                   registrar: @domain.registrar,
                                   current_registrant: @domain.registrant,
                                   new_registrant: @new_registrant)
  end

  def notification
    RegistrantChangeMailer.notice(domain: @domain,
                                  registrar: @domain.registrar,
                                  current_registrant: @domain.registrant,
                                  new_registrant: @new_registrant)
  end

  def confirmation_accepted
    RegistrantChangeMailer.confirmed(domain: @domain,
                                     old_registrant: @domain.registrar)
  end

  def confirmation_rejected
    RegistrantChangeMailer.rejected(domain: @domain,
                                    registrar: @domain.registrar,
                                    registrant: @domain.registrant)
  end

  def confirmation_expired
    RegistrantChangeMailer.expired(domain: @domain,
                                   registrar: @domain.registrar,
                                   registrant: @domain.registrant)
  end
end