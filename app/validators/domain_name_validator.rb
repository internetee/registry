class DomainNameValidator < ActiveModel::EachValidator
  #TODO
  # validates lenght of 2-63
  # validates/honours Estonian additional letters zäõüö
  # honours punicode and all interfces honors utf8
  # validates lower level domains (.pri.ee, edu.ee etc)
  # lower level domains are fixed for .ee and can add statically into settings

  def validate_each(record, attribute, value)
    if !self.class.validate_format(value)
      record.errors[attribute] << (options[:message] || 'invalid format')
    elsif !self.class.validate_reservation(value)
      record.errors[attribute] << (options[:message] || I18n.t('errors.messages.epp_domain_reserved'))
    end
  end

  class << self
    def validate_format(value)
      value = value.mb_chars.downcase.strip

      general_domains = /(.pri.ee|.com.ee|.fie.ee|.med.ee|.ee)/

      # it's punycode
      if value[2] == '-' && value[3] == '-'
        regexp = /\Axn--[a-zA-Z0-9-]{0,59}#{general_domains}\z/
        return false unless value =~ regexp
        value = SimpleIDN.to_unicode(value).mb_chars.downcase.strip
      end

      unicode_chars = /\u00E4\u00F5\u00F6\u00FC\u0161\u017E/ # äõöüšž
      regexp = /\A[a-zA-Z0-9#{unicode_chars}][a-zA-Z0-9#{unicode_chars}-]{0,61}[a-zA-Z0-9#{unicode_chars}]#{general_domains}\z/

      !!(value =~ regexp)
    end

      def validate_reservation(value)
      !ReservedDomain.exists?(name: value.mb_chars.downcase.strip)
    end
  end
end
