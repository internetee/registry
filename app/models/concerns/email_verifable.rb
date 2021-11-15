module EmailVerifable
  extend ActiveSupport::Concern

  included do
    scope :recently_not_validated, -> { where.not(id: ValidationEvent.validated_ids_by(name)) }
  end

  def email_verification_failed?
    need_to_start_force_delete?
  end

  def validate_email_data(level:, count:)
    validation_events.order(created_at: :desc).limit(count).all? do |event|
      event.check_level == level.to_s && event.failed?
    end
  end

  def need_to_start_force_delete?
    flag = false
    ValidationEvent::INVALID_EVENTS_COUNT_BY_LEVEL.each do |level, count|
      if validation_events.count >= count && validate_email_data(level: level, count: count)
        flag = true
      end
    end

    flag
  end

  def need_to_lift_force_delete?
    validation_events.failed.empty? ||
      ValidationEvent::REDEEM_EVENTS_COUNT_BY_LEVEL.any? do |level, count|
        validation_events.order(created_at: :desc).limit(count).all? do |event|
          event.check_level == level.to_s && event.successful?
        end
      end
  end

  def correct_email_format
    return if email.blank?

    result = verify(email: email)
    process_error(:email) unless result
  end

  def correct_billing_email_format
    return if email.blank?

    result = verify(email: billing_email)
    process_error(:billing_email) unless result
  end

  def verify_email(check_level: 'regex')
    verify(email: email, check_level: check_level)
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
