class Contact::Ident::BirthDateValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add(:code, :invalid_birth_date) if birth_date_wrong?(record)
  end

  private

  def birth_date_wrong?(record)
    return unless record.birthday?

    return true if birth_date_format_wrong?(record.code)

    contact_ident_date = Date.parse(record.code)
    date_from = Time.zone.today - 150.years
    date_to = Time.zone.tomorrow
    valid_time_range = date_from...date_to
    return if valid_time_range.cover?(contact_ident_date)

    true
  end

  def birth_date_format_wrong?(date)
    Date.parse(date)
    false
  rescue ArgumentError
    true
  end
end
