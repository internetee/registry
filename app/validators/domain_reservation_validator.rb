class DomainReservationValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless self.class.validate(value)
      record.errors[attribute] << (options[:message] || 'Domain name is reserved or restricted')
    end
  end

  class << self
    def validate(value)
      !ReservedDomain.exists?(name: value.mb_chars.downcase.strip)
    end
  end
end
