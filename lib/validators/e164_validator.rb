class E164Validator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    validator = ActiveModel::Validations::LengthValidator.new(maximum: 17, attributes: attribute)
    validator.validate(record)

    validator = ActiveModel::Validations::FormatValidator.new(with: /\+[0-9]{1,3}\.[0-9]{1,14}?/,
                                                              attributes: attribute)
    validator.validate(record)
  end
end
