class ContactMailerPreview < ActionMailer::Preview
  def email_changed
    # Replace with `Contact.in_use` once https://github.com/internetee/registry/pull/1146 is merged
    contact = Contact.where('EXISTS(SELECT 1 FROM domains WHERE domains.registrant_id = contacts.id)
                             OR
                             EXISTS(SELECT 1 FROM domain_contacts WHERE domain_contacts.contact_id =
                             contacts.id)')

    contact = contact.where.not(email: nil, country_code: nil, ident_country_code: nil, code: nil)
              .take

    ContactMailer.email_changed(contact: contact, old_email: 'old@inbox.test')
  end
end
