require 'test_helper'

class ContactMailerTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @contact = contacts(:john)
    ActionMailer::Base.deliveries.clear
  end

  def test_delivers_email_changed_email
    assert_equal 'john-001', @contact.code
    assert_equal 'john@inbox.test', @contact.email

    email = ContactMailer.email_changed(contact: @contact, old_email: 'john-old@inbox.test')
              .deliver_now

    assert_emails 1
    assert_equal %w[john@inbox.test], email.to
    assert_equal %w[john-old@inbox.test], email.bcc
    assert_equal 'Teie domeenide kontakt epostiaadress on muutunud' \
                 ' / Contact e-mail addresses of your domains have changed [john-001]', email.subject
  end
end