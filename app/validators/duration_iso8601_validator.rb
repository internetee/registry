class DurationIso8601Validator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.present?

    ISO8601::Duration.new(value)
    rescue => _e
      record.errors[attribute] << (options[:message] || record.errors.generate_message(attribute, :unknown_pattern))
  end
end
