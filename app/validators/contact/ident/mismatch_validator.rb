class Contact::Ident::MismatchValidator < ActiveModel::Validator
  Mismatch = Struct.new(:type, :country)

  def self.mismatches
    birthday_restricted_countries.map do |country_code|
      Mismatch.new('birthday', Country.new(country_code))
    end
  end

  def self.birthday_restricted_countries
    Rails.configuration.x.contact_ident_birthday_restricted_countries || []
  end

  def validate(record)
    record.errors.add(:base, :mismatch, type: record.type, country: record.country) if mismatched?(record)
  end

  private

  def mismatched?(record)
    mismatch = Mismatch.new(record.type, record.country)
    self.class.mismatches.include?(mismatch)
  end
end
