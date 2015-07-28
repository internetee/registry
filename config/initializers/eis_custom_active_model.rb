# Log all active model user errors
# rubocop: disable Lint/AssignmentInCondition
# rubocop: disable Style/SignalException
module ActiveModel
  class Errors
    def add(attribute, message = :invalid, options = {})
      message = normalize_message(attribute, message, options)
      if exception = options[:strict]
        exception = ActiveModel::StrictValidationFailed if exception == true
        raise exception, full_message(attribute, message)
      end

      # CUSTOM logging
      Rails.logger.info "USER MSG: ACTIVEMODEL: #{@base.try(:class)} [#{attribute}] #{message}" if message.present?
      # END of CUSTOM logging

      self[attribute] << message
    end
  end
end
