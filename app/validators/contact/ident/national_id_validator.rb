class Contact::Ident::NationalIdValidator < ActiveModel::EachValidator
  COUNTRY_SPECIFIC_VALIDATIONS = {
    'EE' => proc { |code| Isikukood.new(code).valid? },
  }.freeze

  def validate_each(record, attribute, value)
    validation = COUNTRY_SPECIFIC_VALIDATIONS[record.country_code]

    return unless validation

    valid = validation.call(value)
    record.errors.add(attribute, :invalid_national_id, country: record.country) unless valid
  end
end
