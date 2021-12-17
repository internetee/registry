module Actions
  class EmailCheck
    attr_reader :email, :validation_eventable, :check_level

    def initialize(email:, validation_eventable:, check_level: nil)
      @email = email
      @validation_eventable = validation_eventable
      @check_level = check_level || :mx
    end

    def call
      result = check_email(email)
      save_result(result)
      filtering_old_failed_records(result)
      result.success ? log_success : log_failure(result)
      result.success
    end

    private

    def check_email(parsed_email)
      Truemail.validate(parsed_email, with: calculate_check_level).result
    end

    def calculate_check_level
      Rails.env.test? && check_level == 'smtp' ? :mx : check_level.to_sym
    end

    def filtering_old_failed_records(result)
      if @check_level == "mx" && !result.success && validation_eventable.validation_events.count > 3
        validation_eventable.validation_events.order!(created_at: :asc)
        while validation_eventable.validation_events.count > 3
          validation_eventable.validation_events.first.destroy
        end
      end

      if @check_level == "mx" && result.success && validation_eventable.validation_events.count > 1
        validation_eventable.validation_events.order!(created_at: :asc)
        while validation_eventable.validation_events.count > 1
          validation_eventable.validation_events.first.destroy
        end
      end

      if @check_level == "smtp" && validation_eventable.validation_events.count > 1
        validation_eventable.validation_events.order!(created_at: :asc)
        while validation_eventable.validation_events.count > 1
          validation_eventable.validation_events.first.destroy
        end
      end
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
