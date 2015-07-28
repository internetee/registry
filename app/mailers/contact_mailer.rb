class ContactMailer < ApplicationMailer
  # rubocop:disable Metrics/MethodLength
  def email_updated(email, contact)
    return if delivery_off?(contact)

    @contact = contact

    return if whitelist_blocked?(email)
    begin
      mail(to: email, subject: "#{I18n.t(:contact_email_update_subject)} [#{@contact.code}]")
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
  # rubocop:enable Metrics/MethodLength
end
