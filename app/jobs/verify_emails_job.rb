class VerifyEmailsJob < ApplicationJob
  discard_on StandardError

  def perform(contact:, check_level: 'regex')
    # contact = Contact.find_by(id: contact_id)

    # return if check_contact_for_duplicate_mail(contact)

    contact_not_found(contact.id) unless contact
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

  # def check_contact_for_duplicate_mail(contact)
  #   time = Time.zone.now - ValidationEvent::VALIDATION_PERIOD
  #   contact_ids = Contact.where(email: contact.email).where('created_at > ?', time).pluck(:id)
  #
  #   r = ValidationEvent.where(validation_eventable_id: contact_ids).order(created_at: :desc)
  #
  #   r.present?
  # end

  def contact_not_found(contact_id)
    raise StandardError, "Contact with contact_id #{contact_id} not found"
  end

  def validate_check_level(check_level)
    return if valid_check_levels.include? check_level

    raise StandardError, "Check level #{check_level} is invalid"
  end

  def logger
    @logger ||= Rails.logger
  end

  def valid_check_levels
    ValidationEvent::VALID_CHECK_LEVELS
  end
end
