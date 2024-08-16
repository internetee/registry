class RetryGreylistedEmailsJob < ApplicationJob
  queue_as :default

  MAX_RETRY_ATTEMPTS = 10
  INITIAL_RETRY_DELAY = 5.minutes

  def perform
    unique_greylisted_contacts.each do |contact|
      retry_count = 0
      success = false

      while retry_count < MAX_RETRY_ATTEMPTS && !success
        success = retry_email_validation(contact, retry_count)
        retry_count += 1
        sleep(calculate_delay(retry_count)) unless success
      end

      if success
        clear_and_save_successful_validation(contact)
      else
        mark_email_as_invalid(contact)
      end
    end
  end

  private

  def unique_greylisted_contacts
    ValidationEvent.greylisted_smtp_errors
      .select(:validation_eventable_id, :validation_eventable_type)
      .distinct
      .map(&:validation_eventable)
  end

  def retry_email_validation(contact, retry_count)
    result = Truemail.validate(contact.email, with: :smtp).result
    
    contact.validation_events.create(
      event_type: :email_validation,
      success: result.success?,
      event_data: {
        check_level: 'smtp',
        error: result.error,
        retry_count: retry_count
      }
    )

    result.success?
  end

  def calculate_delay(retry_count)
    INITIAL_RETRY_DELAY * (2 ** (retry_count - 1))
  end

  def clear_and_save_successful_validation(contact)
    contact.validation_events.destroy_all
    contact.validation_events.create(
      event_type: :email_validation,
      success: true,
      event_data: { check_level: 'smtp' }
    )
  end

  def mark_email_as_invalid(contact)
    contact.validation_events.destroy_all
    contact.validation_events.create(
      event_type: :email_validation,
      success: false,
      event_data: {
        check_level: 'smtp',
        error: 'Max retry count exceeded'
      }
    )
  end

  # Prevents sleep in test environment
  def sleep(seconds)
    return if Rails.env.test?
    
    super
  end
end