class RegistrantChangeNoticeEmailJob < EmailJob
  queue_as :default

  def perform(domain_id, new_registrant_id)
    domain = Domain.find(domain_id)
    new_registrant = Registrant.find(new_registrant_id)
    @email = new_registrant.email
    log(domain, new_registrant)
    RegistrantChangeMailer.notification(domain: domain,
                                        registrar: domain.registrar,
                                        current_registrant: domain.registrant,
                                        new_registrant: new_registrant).deliver_now
  end

  private

  def log(domain, new_registrant)
    message = "Send RegistrantChangeMailer#notice email for domain #{domain.name} (##{domain.id}) to #{new_registrant.email}"
    logger.info(message)
  end

  def logger
    Rails.logger
  end
end
