module EmailVerifable
  extend ActiveSupport::Concern

  included do
    scope :recently_not_validated, -> { where.not(id: ValidationEvent.validated_ids_by(name)) }
  end

  def validate_email_by_regex_and_mx
    # return if Rails.env.test?

    verify_email(check_level: 'regex')
    verify_email(check_level: 'mx')
  end

  def remove_force_delete_for_valid_contact
    # return if Rails.env.test?

    domains.each do |domain|
      contact_emails_valid?(domain) ? domain.cancel_force_delete : nil
    end
  end

  def contact_emails_valid?(domain)
    domain.contacts.each do |c|
      return false unless c.need_to_lift_force_delete?
    end

    domain.registrant.need_to_lift_force_delete?
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
    ValidationEvent::INVALID_EVENTS_COUNT_BY_LEVEL.any? do |level, count|
      validation_events.count >= count && validate_email_data(level: level, count: count)
    end
  end

  def need_to_lift_force_delete?
    return true if validation_events.failed.empty?

    ValidationEvent::REDEEM_EVENTS_COUNT_BY_LEVEL.any? do |level, count|
      validation_events.order(created_at: :desc)
                       .limit(count)
                       .all? { |event| event.check_level == level.to_s && event.successful? }
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

  def process_error(field)
    errors.add(field, I18n.t('activerecord.errors.models.contact.attributes.email.email_regex_check_error'))
  end
end
