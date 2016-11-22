class RegistrantChangeNoticeEmailJob < Que::Job
  def run(domain_id, new_registrant_id)
    domain = Domain.find(domain_id)
    new_registrant = Registrant.find(new_registrant_id)
    log(domain, new_registrant)
    RegistrantChangeMailer.notice(domain: domain,
                                  registrar: domain.registrar,
                                  current_registrant: domain.registrant,
                                  new_registrant: new_registrant).deliver_now
  end

  private

  def log(domain, new_registrant)
    message = "Send RegistrantChangeMailer#notice email for domain ##{domain.id} to #{new_registrant.email}"
    logger.info(message)
  end

  def logger
    Rails.logger
  end
end
