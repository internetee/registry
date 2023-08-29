module Actions
  class EmailCheck
    attr_reader :email, :validation_eventable, :check_level

    SAVE_RESULTS_BATCH_SIZE = 500

    def initialize(email:, validation_eventable:, check_level: nil)
      @email = email
      @validation_eventable = validation_eventable
      @check_level = check_level || :mx
    end

    def call
      result = check_email(email)
      save_result(result)
      handle_logging(result)
      result.success
    end

    private

    def check_email(parsed_email)
      Truemail.validate(parsed_email, with: calculate_check_level).result
    end

    def calculate_check_level
      return :mx if Rails.env.test? && check_level == 'smtp'

      check_level.to_sym
    end

    def filter_old_failed_records(result, contact)
      ValidationEvent::INVALID_EVENTS_COUNT_BY_LEVEL.each do |level, limit|
        handle_failed_records(contact: contact, check_level: level, limit: limit, success: result.success)
      end
    end

    def handle_failed_records(contact:, check_level:, limit:, success:)
      return unless @check_level.to_sym == check_level.to_sym && !success

      excess_events_count = contact.validation_events.count - limit
      return unless excess_events_count.positive?

      contact.validation_events.order(created_at: :asc).limit(excess_events_count).destroy_all
    end

    def filter_old_records(contact:, success:)
      contact.validation_events.destroy_all if success
    end

    def save_result(result)
      contacts = Contact.where(email: email)

      handle_mx_validation(result) if !result.success && @check_level == 'mx'

      result.configuration = nil

      contacts.find_in_batches(batch_size: SAVE_RESULTS_BATCH_SIZE) do |contact_batches|
        contact_batches.each do |contact|
          handle_saving_result(contact, result)
        end
      end
    rescue ActiveRecord::RecordNotSaved
      logger.info "Cannot save validation result for #{log_object_id}" and return true
    end

    def handle_mx_validation(result)
      result_validation = Actions::AAndAaaaEmailValidation.call(email: email, value: 'A')
      output_a_and_aaaa_validation_results(email: email, result: result_validation, type: 'A')

      if result_validation.empty?
        result_validation = Actions::AAndAaaaEmailValidation.call(email: email, value: 'AAAA')
        output_a_and_aaaa_validation_results(email: email, result: result_validation, type: 'AAAA')
      end

      return if result_validation.blank?

      result.success = true
      result.errors.merge!({ mx: 'target host(s) not found, but was able to find A/AAAA records for domain' })
    end

    def handle_saving_result(contact, result)
      filter_old_records(contact: contact, success: result.success)
      contact.validation_events.create!(validation_event_attrs(result))
      filter_old_failed_records(result, contact)
    end

    def output_a_and_aaaa_validation_results(email:, result:, type:)
      return if Rails.env.test?

      logger.info "Validated #{type} record for #{email}. Validation result - #{result}"
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

    def handle_logging(result)
      if result.success
        logger.info "Successfully validated email #{email} for #{log_object_id}."
      else
        logger.info "Failed to validate email #{email} for #{log_object_id}."
        logger.info "Validation level #{check_level}, the result was #{result}"
      end
    end

    def log_object_id
      "#{validation_eventable.class}: #{validation_eventable.id}"
    end
  end
end
