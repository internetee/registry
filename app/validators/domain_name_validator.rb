class DomainNameValidator < ActiveModel::EachValidator
  #TODO 
  # validates lenght of 2-63
  # validates/honours Estonian additional letters zäõüö
  # honours punicode and all interfces honors utf8
  # validates lower level domains (.pri.ee, edu.ee etc)
  # lower level domains are fixed for .ee and can add statically into settings

  def validate_each(record, attribute, value)
    unless self.class.validate(value)
      record.errors[attribute] << (options[:message] || 'invalid format')
    end
  end

  class << self
    def validate(value)
      ok = value =~ /\A[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]\.ee\z/
      ok &&= !(value[2] == '-' && value[3] == '-')
    end
  end
end
