class Iso31661Alpha2Validator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :invalid_iso31661_alpha2) unless valid_country_code?(value)
  end

  private

  def valid_country_code?(country_code)
    Country.new(country_code)
  end
end
