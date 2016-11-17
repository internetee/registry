class RegistrantChangeConfirmEmailJob < Que::Job
  def run(domain_id, new_registrant_id)
    domain = Domain.find(domain_id)
    new_registrant = Registrant.find(new_registrant_id)

    RegistrantChangeMailer.confirm(domain: domain,
                                   registrar: domain.registrar,
                                   current_registrant: domain.registrant,
                                   new_registrant: new_registrant).deliver_now
  end
end
