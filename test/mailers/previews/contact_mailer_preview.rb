class ContactMailerPreview < ActionMailer::Preview
  def email_changed
    contact = Contact.linked
    contact = contact.where.not(email: nil, country_code: nil, code: nil).first

    ContactMailer.email_changed(contact: contact, old_email: 'old@inbox.test')
  end
end