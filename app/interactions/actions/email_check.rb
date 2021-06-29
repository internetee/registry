module Actions
  class EmailCheck
    attr_reader :email, :validation_eventable, :check_level

    def initialize(email:, validation_eventable:, check_level: nil)
      @email = email
      @validation_eventable = validation_eventable
      @check_level = check_level || :regex
    end

    def call
      result = check_email
      save_result(result)
      log_failure(result) unless result.success
      result.success
    end

    private

    def check_email
      Truemail.validate(email, with: check_level).result
    end

    def save_result(result)
      validation_eventable.validation_events.create(validation_event_attrs(result))
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

    def log_object_id
      "#{validation_eventable.class}: #{validation_eventable.id}"
    end
  end
end
