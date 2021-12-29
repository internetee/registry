module Actions
  module SimpleMailValidator
    extend self

    def run(email:, level:)
      result = truemail_validate(email: email, level: level)
      result = validate_for_a_and_aaaa_records(email) if !result && level == :mx
      result
    end

    def truemail_validate(email:, level:)
      Truemail.validate(email, with: level).result.success
    end

    def validate_for_a_and_aaaa_records(email)
      result_validation = Actions::AAndAaaaEmailValidation.call(email: email, value: 'A')
      output_a_and_aaaa_validation_results(email: email,
                                           result: result_validation,
                                           type: 'A')

      result_validation = Actions::AAndAaaaEmailValidation.call(email: email, value: 'AAAA') if result_validation.empty?
      output_a_and_aaaa_validation_results(email: email,
                                           result: result_validation,
                                           type: 'AAAA')

      result_validation.present? ? true : false
    end

    def output_a_and_aaaa_validation_results(email:, result:, type:)
      return if Rails.env.test?

      logger.info "Validated #{type} record for #{email}. Validation result - #{result}"
    end

    def logger
      @logger ||= Rails.logger
    end
  end
end
