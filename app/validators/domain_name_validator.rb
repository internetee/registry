class DomainNameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    ok = value =~ /\A[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]\.ee\z/
    ok &&= !(value[2] == '-' && value[3] == '-')

    unless ok
      record.errors[attribute] << (options[:message] || 'invalid format')
    end
  end
end
