class Contact::Ident::RegNoValidator < ActiveModel::EachValidator
  COUNTRY_SPECIFIC_FORMATS = {
    'EE' => /\A[0-9]{8}\z/,
  }.freeze

  def validate_each(record, attribute, value)
    format = COUNTRY_SPECIFIC_FORMATS[record.country_code]

    return unless format

    return if value.match?(format)

    record.errors.add(attribute, :invalid_reg_no, country: record.country)
  end
end
