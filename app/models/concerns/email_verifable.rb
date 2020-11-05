module Concerns
  module EmailVerifable
    extend ActiveSupport::Concern

    def email_verification
      @email_verification ||= EmailAddressVerification.find_or_create_by(email: unicode_email,
                                                                         domain: domain(email))
    end

    def billing_email_verification
      return unless attribute_names.include?('billing_email')

      @billing_email_verification ||= EmailAddressVerification
                                      .find_or_create_by(email: unicode_billing_email,
                                                         domain: domain(billing_email))
    end

    def email_verification_failed?
      email_verification&.failed?
    end

    class_methods do
      def domain(email)
        Mail::Address.new(email).domain&.downcase || 'not_found'
      rescue Mail::Field::IncompleteParseError
        'not_found'
      end

      def local(email)
        Mail::Address.new(email).local&.downcase || email
      rescue Mail::Field::IncompleteParseError
        email
      end

      def punycode_to_unicode(email)
        return email if domain(email) == 'not_found'

        local = local(email)
        domain = SimpleIDN.to_unicode(domain(email))
        "#{local}@#{domain}"&.downcase
      end

      def unicode_to_punycode(email)
        return email if domain(email) == 'not_found'

        local = local(email)
        domain = SimpleIDN.to_ascii(domain(email))
        "#{local}@#{domain}"&.downcase
      end
    end

    def unicode_billing_email
      self.class.punycode_to_unicode(billing_email)
    end

    def unicode_email
      self.class.punycode_to_unicode(email)
    end

    def domain(email)
      SimpleIDN.to_unicode(self.class.domain(email))
    end

    def punycode_to_unicode(email)
      self.class.punycode_to_unicode(email)
    end

    def correct_email_format
      return if email.blank?

      result = email_verification.verify
      process_result(result: result, field: :email)
    end

    def correct_billing_email_format
      return if email.blank?

      result = billing_email_verification.verify
      process_result(result: result, field: :billing_email)
    end

    # rubocop:disable Metrics/LineLength
    def process_result(result:, field:)
      case result[:errors].keys.first
      when :smtp
        errors.add(field, I18n.t('activerecord.errors.models.contact.attributes.email.email_smtp_check_error'))
      when :mx
        errors.add(field, I18n.t('activerecord.errors.models.contact.attributes.email.email_mx_check_error'))
      when :regex
        errors.add(field, I18n.t('activerecord.errors.models.contact.attributes.email.email_regex_check_error'))
      end
    end
    # rubocop:enable Metrics/LineLength
  end
end
