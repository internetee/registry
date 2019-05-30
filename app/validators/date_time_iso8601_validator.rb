class DateTimeIso8601Validator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if self.class.validate(value)

    record.errors[attribute] << (options[:message] || I18n.t('unknown_expiry_absolute_pattern'))
  end

  class << self
    def validate(value)
      return true if value.empty?

      begin
        DateTime.zone.parse(value)
      rescue StandardError => _e
        return false
      end

      true
    end

    def validate_epp(obj, value)
      return if validate(value)

      {
        code: '2005',
        msg: I18n.t(:unknown_expiry_absolute_pattern),
        value: { obj: obj, val: value },
      }
    end
  end
end
