module EmailVerifable
  extend ActiveSupport::Concern

  included do
    scope :recently_not_validated, -> { where.not(id: ValidationEvent.validated_ids_by(name)) }
  end

  def validate_email_by_regex_and_mx(single_email: false)
    verify_email(check_level: 'regex', single_email: single_email)
    verify_email(check_level: 'mx', single_email: single_email)
  end

  def remove_force_delete_for_valid_contact
    domain_with_fd = domains.select(&:force_delete_scheduled?)

    domain_with_fd.each do |domain|
      cancel_force_delete_if_domain_attributes_are_valid?(domain)
    end
  end

  def cancel_force_delete_if_domain_attributes_are_valid?(domain)
    return if domain.template_name == 'invalid_company'

    domain.cancel_force_delete if contact_emails_valid?(domain) && !is_domain_has_invalid_org_contact?(domain)
  end

  def is_domain_has_invalid_org_contact?(domain)
    return unless domain.force_delete_scheduled?

    domain.status_notes.any? { |note| note.include?("Company no: #{domain.registrant.identifier.code}") }
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

  def verify_email(check_level: 'regex', single_email: false)
    verify(email: email, check_level: check_level, single_email: single_email)
  end

  def verify(email:, check_level: 'regex', single_email: false)
    action = Actions::EmailCheck.new(email: email,
                                     validation_eventable: self,
                                     check_level: check_level,
                                     single_email: single_email)
    action.call
  end

  # rubocop:disable Metrics/LineLength
  def process_error(field)
    errors.add(field, I18n.t('activerecord.errors.models.contact.attributes.email.email_regex_check_error'))
  end
  # rubocop:enable Metrics/LineLength
end
