class FillEmailVerifications < ActiveRecord::Migration[6.0]
  def up
    # registrar_billing_emails = Registrar.pluck(:billing_email).uniq.reject(&:blank?)
    # registrar_emails = Registrar.pluck(:email).uniq.reject(&:blank?)
    # contact_emails = Contact.pluck(:email).uniq.reject(&:blank?)
    #
    # emails = (contact_emails + registrar_emails + registrar_billing_emails)
    # emails = emails.map{ |email| punycode_to_unicode(email) }.uniq
    #
    # result = emails.map do |email|
    #   { email: email, domain: domain(email) }
    # end
    # EmailAddressVerification.import result, batch_size: 500 #deprecated/removed
    # need to use insert_all if uncommented
  end

  def down
    # EmailAddressVerification table removed in 20220413073315_remove_email_address_verifications
  end
end
