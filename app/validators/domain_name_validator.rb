class DomainNameValidator < ActiveModel::EachValidator
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/LineLength
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
        return false unless value.match?(regexp)
        value = SimpleIDN.to_unicode(value).mb_chars.downcase.strip
      end

      unicode_chars = /\u00E4\u00F5\u00F6\u00FC\u0161\u017E/ # äõöüšž
      regexp = /\A[a-zA-Z0-9#{unicode_chars.source}][a-zA-Z0-9#{unicode_chars.source}-]{0,62}\.#{general_domains.source}\z/
      end_regexp = /\-\.#{general_domains.source}\z/ # should not contain dash as a closing char
      !!(value =~ regexp && value !~ end_regexp)
    end

    def validate_blocked(value)
      return true unless value
      return false if BlockedDomain.where(name: value).any?
      return false if BlockedDomain.where(name: SimpleIDN.to_unicode(value)).any?

      DNS::Zone.where(origin: value).count.zero?
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/LineLength
end
