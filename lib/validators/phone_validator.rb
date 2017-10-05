class PhoneValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if record.errors[:phone].any?

    splitted_phone = value.split('.')
    country_code = splitted_phone.first
    phone_number = splitted_phone.second

    if zeros_only?(country_code) || zeros_only?(phone_number)
      record.errors.add(attribute, :invalid)
    end
  end

  private

  def zeros_only?(value)
    value.delete('0+').empty?
  end
end
