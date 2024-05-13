class VerifyEmailsJob < ApplicationJob
  discard_on StandardError

  def perform(email:, check_level: 'mx', force: false)
    contact = fetch_contact(email)
    return unless contact && need_to_verify?(contact, force)

    verify_contact_email(contact, check_level)
  rescue StandardError => e
    handle_error(e)
  end

  private

  def fetch_contact(email)
    contact = Contact.find_by(email: email)
    logger.info "Contact #{email} not found!" unless contact
    contact
  end

  def verify_contact_email(contact, check_level)
    validate_check_level(check_level)
    logger.info "Trying to verify contact email #{contact.email} with check_level #{check_level}"
    contact.verify_email(check_level: check_level)
  end

  def validate_check_level(check_level)
    return if valid_check_levels.include? check_level

    raise StandardError, "Check level #{check_level} is invalid"
  end

  def need_to_verify?(contact, force)
    return true if contact.validation_events.empty? || force

    last_validation = contact.validation_events.last
    expired_last_validation = last_validation.successful? && last_validation.created_at < validation_expiry_date
    failed_last_regex_validation = last_validation.failed? && last_validation.event_data['check_level'] == 'regex'

    return true if expired_last_validation

    !failed_last_regex_validation
  end

  def logger
    @logger ||= Rails.logger
  end

  def valid_check_levels
    ValidationEvent::VALID_CHECK_LEVELS
  end

  def validation_expiry_date
    Time.zone.now - ValidationEvent::VALIDATION_PERIOD
  end

  def handle_error(error)
    logger.error error.message
    raise error
  end
end
