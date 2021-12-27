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
      if !result.success && @check_level == "mx"
        email_domain = Mail::Address.new(@email).domain

        result_validation = check_for_records_value(domain: email_domain, value: 'A')
        logger.info "Validated A record for #{email_domain}. Validation result - #{result_validation}"
        p "Validated A record for #{email_domain}. Validation result - #{result_validation}"

        result_validation = check_for_records_value(domain: email_domain, value: 'AAAA') if result_validation.empty?
        logger.info "Validated AAAA record for #{email_domain}. Validation result - #{result_validation}" if result_validation.empty?
        p "Validated AAAA record for #{email_domain}. Validation result - #{result_validation}" if result_validation.empty?

        result_validation.present? ? result.success = true : result.success = false

        validation_eventable.validation_events.create(validation_event_attrs(result))
      else
        validation_eventable.validation_events.create(validation_event_attrs(result))
      end
    rescue ActiveRecord::RecordNotSaved
      logger.info "Cannot save validation result for #{log_object_id}"
      true
    end

    def check_for_records_value(domain:, value:)
      result = nil
      dns_servers = ENV['dnssec_resolver_ips'].to_s.split(',').map(&:strip)

      Resolv::DNS.open({ nameserver: dns_servers }) do |dns|
        dns.timeouts = ENV['a_and_aaaa_validation_timeout'].to_i || 1
        ress = nil

        case value
        when 'A'
          ress = dns.getresources domain, Resolv::DNS::Resource::IN::A
        when 'AAAA'
          ress = dns.getresources domain, Resolv::DNS::Resource::IN::AAAA
        end

        result = ress.map { |r| r.address }
      end

      result
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
