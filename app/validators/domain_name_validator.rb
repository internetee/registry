class DomainNameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if !self.class.validate_format(value)
      record.errors[attribute] << (options[:message] || record.errors.generate_message(attribute, :invalid))
    elsif !self.class.validate_blocked(value)
      record.errors.add(:base, :domain_name_blocked)
    end
  end

  class << self
    def validate_format(value)
      return true unless value
      value = value.mb_chars.downcase.strip

      origins = DNS::Zone.origins
      # if someone tries to register an origin domain, let this validation pass
      # the error will be caught in blocked domains validator
      return true if origins.include?(value)

      general_domains = /(#{origins.join('|')})/

      # it's punycode
      if value[2] == '-' && value[3] == '-'
        regexp = /\Axn--[a-zA-Z0-9-]{0,59}\.#{general_domains}\z/
        return false unless value =~ regexp
        value = SimpleIDN.to_unicode(value).mb_chars.downcase.strip
      end

      # rubocop: disable Metrics/LineLength
      unicode_chars = /\u00E4\u00F5\u00F6\u00FC\u0161\u017E/ # äõöüšž
      regexp = /\A[a-zA-Z0-9#{unicode_chars.source}][a-zA-Z0-9#{unicode_chars.source}-]{0,61}[a-zA-Z0-9#{unicode_chars.source}]\.#{general_domains.source}\z/
      # rubocop: enable Metrics/LineLength
      # rubocop: disable Style/DoubleNegation
      !!(value =~ regexp)
      # rubocop: enable Style/DoubleNegation
    end

    def validate_blocked(value)
      return true unless value
      return false if BlockedDomain.where(name: value).count.positive?
      DNS::Zone.where(origin: value).count.zero?
    end
  end
end
