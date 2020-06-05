module Concerns
  module EmailCheckable
    extend ActiveSupport::Concern

    def email_verification
      EmailAddressVerification.find_or_create_by(email: self.email)
    end

    def billing_email_verification
      if self.attribute_names.include?('billing_email')
        EmailAddressVerification.find_or_create_by(email: self.billing_email)
      else
        nil
      end
    end

    def verify_email_mx_smtp(field:, email:)
      errors.add(field, :invalid) unless email.blank? || Truemail.valid?(email)
    end

    def correct_email_format
      verify_email_mx_smtp(field: :email, email: email)
    end

    def correct_billing_email_format
      return if self[:billing_email].blank?

      verify_email_mx_smtp(field: :billing_email, email: billing_email)
    end
  end
end
