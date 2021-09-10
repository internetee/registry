class Contact::Ident::BirthDateValidator < ActiveModel::Validator
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
    date_from = Time.zone.today - 150.years
    date_to = Time.zone.tomorrow
    valid_time_range = date_from...date_to
    return if valid_time_range.cover?(contact_ident_date)

    true
  end
end
