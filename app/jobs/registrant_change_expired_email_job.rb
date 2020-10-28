class RegistrantChangeExpiredEmailJob < EmailJob
  queue_as :default

  def perform(domain_id)
    domain = Domain.find(domain_id)
    @email = domain.new_registrant_email
    log(domain)
    RegistrantChangeMailer.expired(domain: domain,
                                   registrar: domain.registrar,
                                   registrant: domain.registrant).deliver_now
  end

  private

  def log(domain)
    message = "Send RegistrantChangeMailer#expired email for domain #{domain.name} (##{domain.id}) to #{domain.new_registrant_email}"
    logger.info(message)
  end

  def logger
    Rails.logger
  end
end
