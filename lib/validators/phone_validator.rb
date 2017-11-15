class PhoneValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if record.errors[:phone].any?

    phone_parts = value.split('.')
    country_code = phone_parts.first
    subscriber_no = phone_parts.second

    if zeros_only?(country_code) || zeros_only?(subscriber_no)
      record.errors.add(attribute, :invalid)
    end
  end

  private

  def zeros_only?(value)
    value.delete('0+').empty?
  end
end
