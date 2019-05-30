class DurationIso8601Validator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if self.class.validate(value)

    record.errors[attribute] << (options[:message] || record.errors.generate_message(attribute, :unknown_pattern))
  end

  class << self
    def validate(value)
      return true if value.blank?
      return true if value.empty?

      begin
        ISO8601::Duration.new(value)
      rescue StandardError => _e
        return false
      end

      true
    end

    def validate_epp(obj, value)
      return if validate(value)

      {
        code: '2005',
        msg: I18n.t(:unknown_expiry_relative_pattern),
        value: { obj: obj, val: value },
      }
    end
  end
end
