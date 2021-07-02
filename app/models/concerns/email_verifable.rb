module EmailVerifable
  extend ActiveSupport::Concern

  included do
    scope :recently_not_validated, -> { where.not(id: ValidationEvent.validated_ids_by(name)) }
  end

  def email_verification_failed?
    email_validations_present?(valid: false)
  end

  def email_validations_present?(valid: true)
    base_scope = valid ? recent_email_validations : recent_failed_email_validations
    check_levels = ValidationEvent::VALID_CHECK_LEVELS
    event_count_sum = 0
    check_levels.each do |level|
      event_count = base_scope.select { |event| event.check_level == level }.count
      event_count_sum += event_count
    end

    event_count_sum > ValidationEvent::VALID_EVENTS_COUNT_THRESHOLD
  end

  def recent_email_validations
    validation_events.email_validation_event_type.successful.recent
  end

  def recent_failed_email_validations
    validation_events.email_validation_event_type.failed.recent
  end

  # TODO: Validation method, needs to be changed
  def correct_email_format
    return if email.blank?

    result = verify(email: email)
    process_error(:email) unless result
  end

  # TODO: Validation method, needs to be changed
  def correct_billing_email_format
    return if email.blank?

    result = verify(email: billing_email)
    process_error(:billing_email) unless result
  end

  def verify(email:, check_level: 'regex')
    action = Actions::EmailCheck.new(email: email,
                                     validation_eventable: self,
                                     check_level: check_level)
    action.call
  end

  # rubocop:disable Metrics/LineLength
  def process_error(field)
    errors.add(field, I18n.t('activerecord.errors.models.contact.attributes.email.email_regex_check_error'))
  end
  # rubocop:enable Metrics/LineLength
end
