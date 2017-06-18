class ContactMailer < ApplicationMailer
  include Que::Mailer
  helper_method :address_processing

  def email_updated(old_email, email, contact_id, should_deliver)
    @contact   = Contact.find_by(id: contact_id)
    @old_email = old_email
    unless @contact
      Rails.logger.info "Cannot send email in #{self.class.name}##{__method__} with contact_id #{contact_id}. It cannot be found"
      return
    end


    return unless email || @contact
    return if delivery_off?(@contact, should_deliver)
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

  private

  def address_processing
    Contact.address_processing?
  end
end
