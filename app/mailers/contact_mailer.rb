class ContactMailer < ApplicationMailer
  include Que::Mailer

  def email_updated(email_id, contact_id)
    email = Email.find_by(id: email_id)
    @contact = Contact.find_by(id: contact_id)
    return unless email || @contact
    return if delivery_off?(contact)
    return if whitelist_blocked?(email)

    begin
      mail(to: format(email), subject: "#{I18n.t(:contact_email_update_subject)} [#{@contact.code}]")
    rescue EOFError,
           IOError,
           TimeoutError,
           Errno::ECONNRESET,
           Errno::ECONNABORTED,
           Errno::EPIPE,
           Errno::ETIMEDOUT,
           Net::SMTPAuthenticationError,
           Net::SMTPServerBusy,
           Net::SMTPFatalError,
           Net::SMTPSyntaxError,
           Net::SMTPUnknownError,
           OpenSSL::SSL::SSLError => e
      logger.info "EMAIL SENDING FAILED: #{email}: #{e}"
    end
  end
end
