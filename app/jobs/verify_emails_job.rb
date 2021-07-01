class VerifyEmailsJob < ApplicationJob
  discard_on StandardError
  VALID_CHECK_LEVELS = %w[regex mx smtp].freeze

  def perform(contact_id:, check_level: 'regex')
    contact = Contact.find_by(id: contact_id)
    contact_not_found(contact_id) unless contact
    validate_check_level(check_level)

    action = Actions::EmailCheck.new(email: contact.email,
                                     validation_eventable: contact,
                                     check_level: check_level)
    action.call
  rescue StandardError => e
    logger.error e.message
    raise e
  end

  private

  def contact_not_found(contact_id)
    raise StandardError, "Contact with contact_id #{contact_id} not found"
  end

  def validate_check_level(check_level)
    return if VALID_CHECK_LEVELS.include? check_level

    raise StandardError, "Check level #{check_level} is invalid"
  end

  def logger
    @logger ||= Rails.logger
  end
end
