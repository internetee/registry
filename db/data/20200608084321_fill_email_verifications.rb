class FillEmailVerifications < ActiveRecord::Migration[6.0]
  def up
    registrar_billing_emails = Registrar.pluck(:billing_email).uniq.reject(&:blank?).map(&:downcase)
    registrar_emails = Registrar.pluck(:email).uniq.reject(&:blank?).map(&:downcase)
    contact_emails = Contact.pluck(:email).uniq.reject(&:blank?).map(&:downcase)

    emails = (contact_emails + registrar_emails + registrar_billing_emails).uniq

    result = emails.map do |email|
      { email: email, domain: domain(email) }
    end
    EmailAddressVerification.import result, batch_size: 500
  end

  def down
    EmailAddressVerification.delete_all
  end

  def domain(email)
    Mail::Address.new(email).domain || 'not_found'
  rescue Mail::Field::IncompleteParseError
    'not_found'
  end
end
