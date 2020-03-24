class Ident::NationalIdValidator < ActiveModel::EachValidator
  def self.country_specific_validations
    {
      Country.new('EE') => proc { |code| Isikukood.new(code).valid? },
    }
  end

  def validate_each(record, attribute, value)
    validation = validation_for(record.country)

    return unless validation

    valid = validation.call(value)
    record.errors.add(attribute, :invalid_national_id, country: record.country) unless valid
  end

  private

  def validation_for(country)
    self.class.country_specific_validations[country]
  end
end
