module Concerns
  module EmailVerifable
    extend ActiveSupport::Concern

    def email_verification
      EmailAddressVerification.find_or_create_by(email: self.class.punycode_to_unicode(email),
                                                 domain: domain(email))
    end

    def billing_email_verification
      return unless attribute_names.include?('billing_email')

      EmailAddressVerification.find_or_create_by(email: self.class
                                                            .punycode_to_unicode(billing_email),
                                                 domain: domain(billing_email))
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

    def domain(email)
      SimpleIDN.to_unicode(self.class.domain(email))
    end

    def punycode_to_unicode(email)
      self.class.punycode_to_unicode(email)
    end

    def verify_email_mx_smtp(field:, email:)
      errors.add(field, :invalid) unless email.blank? || Truemail.valid?(email)
    end

    def correct_email_format
      verify_email_mx_smtp(field: :email, email: email)
    end

    def correct_billing_email_format
      verify_email_mx_smtp(field: :billing_email, email: billing_email)
    end
  end
end
