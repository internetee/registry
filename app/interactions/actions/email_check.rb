module Actions
  class EmailCheck
    attr_reader :email, :validation_eventable, :check_level

    def initialize(email:, validation_eventable:, check_level: nil)
      @email = email
      @validation_eventable = validation_eventable
      @check_level = check_level || :regex
    end

    def call
      parsed_email = EmailAddressConverter.punycode_to_unicode(email)
      result = check_email(parsed_email)
      save_result(result)
      result.success ? log_success : log_failure(result)
      result.success
    end

    private

    def check_email(parsed_email)
      Truemail.validate(parsed_email, with: check_level.to_sym).result
    end

    def save_result(result)
      validation_eventable.validation_events.create(validation_event_attrs(result))
    rescue ActiveRecord::RecordNotSaved
      logger.info "Cannot save validation result for #{log_object_id}"
      true
    end

    def validation_event_attrs(result)
      {
        event_data: event_data(result),
        event_type: ValidationEvent::EventType::TYPES[:email_validation],
        success: result.success,
      }
    end

    def logger
      @logger ||= Rails.logger
    end

    def event_data(result)
      result.to_h.merge(check_level: check_level)
    end

    def log_failure(result)
      logger.info "Failed to validate email #{email} for the #{log_object_id}."
      logger.info "Validation level #{check_level}, the result was #{result}"
    end

    def log_success
      logger.info "Successfully validated email #{email} for the #{log_object_id}."
    end

    def log_object_id
      "#{validation_eventable.class}: #{validation_eventable.id}"
    end
  end
end
