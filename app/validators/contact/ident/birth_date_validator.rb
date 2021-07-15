class Contact::Ident::BirthDateValidator < ActiveModel::Validator
  VALID_BIRTH_DATE_FROM = Time.zone.today - 150.years
  VALID_BIRTH_DATE_TO = Time.zone.tomorrow

  def validate(record)
    record.errors.add(:code, :invalid_birth_date) if birth_date_wrong?(record)
  end

  private

  def birth_date_wrong?(record)
    return unless record.birthday?

    begin
      Date.parse(record.code)
    rescue ArgumentError
      return true
    end

    contact_ident_date = Date.parse(record.code)
    valid_time_range = VALID_BIRTH_DATE_FROM...VALID_BIRTH_DATE_TO
    return if valid_time_range.cover?(contact_ident_date)

    true
  end
end
