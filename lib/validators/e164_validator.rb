class E164Validator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    length_validator = ActiveModel::Validations::
            LengthValidator.new(maximum: 17, attributes: attribute)
    length_validator.validate(record)

    format_validator = ActiveModel::Validations::
            FormatValidator.new(with: /\+[0-9]{1,3}\.[0-9]{1,14}?/,
                                attributes: attribute)
    format_validator.validate(record)
  end
end
