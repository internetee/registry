class ContactMailer < ApplicationMailer
  # rubocop:disable Metrics/MethodLength
  def email_updated(contact)
    return if delivery_off?(contact)

    @contact = contact
    emails = []
    emails << [@contact.email, @contact.email_was] if @contact.registrant_domains.present?
    emails << @contact.domains.map(&:registrant_email) if @contact.domains.present?
    emails = emails.uniq

    return if whitelist_blocked?(emails)
    emails.each do |email|
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
        logger.warn "EMAIL SENDING FAILED: #{email}: #{e}"
      end
    end
  end
  # rubocop:enable Metrics/MethodLength
end
