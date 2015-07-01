class DomainNameValidator < ActiveModel::EachValidator
  # rubocop: disable Metrics/PerceivedComplexity
  # rubocop: disable Metrics/CyclomaticComplexity
  def validate_each(record, attribute, value)
    if !self.class.validate_format(value)
      record.errors[attribute] << (options[:message] || record.errors.generate_message(attribute, :invalid))
    elsif !self.class.validate_blocked(value)
      record.errors.add(attribute, (options[:message] || record.errors.generate_message(attribute, :blocked)))
    elsif !self.class.validate_reservation(value)
      record.errors.add(attribute, (options[:message] || record.errors.generate_message(attribute, :reserved)))
    end
  end
  # rubocop: enable Metrics/PerceivedComplexity
  # rubocop: enable Metrics/CyclomaticComplexity

  class << self
    def validate_format(value)
      return true if value == 'ee'
      return true unless value
      value = value.mb_chars.downcase.strip

      general_domains = /(.pri.ee|.com.ee|.fie.ee|.med.ee|.ee)/

      # it's punycode
      if value[2] == '-' && value[3] == '-'
        regexp = /\Axn--[a-zA-Z0-9-]{0,59}#{general_domains}\z/
        return false unless value =~ regexp
        value = SimpleIDN.to_unicode(value).mb_chars.downcase.strip
      end

      # rubocop: disable Metrics/LineLength
      unicode_chars = /\u00E4\u00F5\u00F6\u00FC\u0161\u017E/ # äõöüšž
      regexp = /\A[a-zA-Z0-9#{unicode_chars.source}][a-zA-Z0-9#{unicode_chars.source}-]{0,61}[a-zA-Z0-9#{unicode_chars.source}]#{general_domains.source}\z/
      # rubocop: enable Metrics/LineLength
      # rubocop: disable Style/DoubleNegation
      !!(value =~ regexp)
      # rubocop: enable Style/DoubleNegation
    end

    def validate_blocked(value)
      return true unless value
      BlockedDomain.where("names @> ?::varchar[]", "{#{value}}").count == 0
    end

    def validate_reservation(value)
      return true unless value
      !ReservedDomain.exists?(name: value.mb_chars.downcase.strip)
    end
  end
end
