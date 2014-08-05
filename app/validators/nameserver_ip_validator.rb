class NameserverIpValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if record.domain_

    if !self.class.validate_format(value)
      record.errors.add(attribute, (options[:message] || :invalid))
    end
  end

  class << self
    def validate_format(value)
      !!(value =~ /\A(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])\z/)
    end
  end
end
