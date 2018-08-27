class Contact::Ident::RegNoValidator < ActiveModel::EachValidator
  def self.country_specific_formats
    {
      Country.new('EE') => /\A[0-9]{8}\z/,
    }
  end

  def validate_each(record, attribute, value)
    format = format_for(record.country)

    return unless format

    return if value.match?(format)
    record.errors.add(attribute, :invalid_reg_no, country: record.country)
  end

  private

  def format_for(country)
    self.class.country_specific_formats[country]
  end
end
