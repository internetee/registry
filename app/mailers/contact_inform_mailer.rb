class ContactInformMailer < ApplicationMailer
  helper_method :address_processing

  def notify(contact:, subject:)
    @contact = email
    @subject = subject

    mail(to: contact.email, subject: subject)
  end

  private

  def address_processing
    Contact.address_processing?
  end
end
