class Contact::Ident::CodeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless record.country_code == 'EE'

    if record.national_id? && !valid_national_id_ee?(value)
      record.errors.add(attribute,
                        :invalid_national_id,
                        country: record.country)
    end

    if record.reg_no?
      validator = ActiveModel::Validations::
              FormatValidator.new(with: reg_no_ee_format,
                                  attributes: attribute,
                                  message: :invalid_reg_no,
                                  country: record.country)
      validator.validate(record)
    end
  end

  private

  def reg_no_ee_format
    /\A[0-9]{8}\z/
  end

  def valid_national_id_ee?(ident)
    Isikukood.new(ident).valid?
  end
end
